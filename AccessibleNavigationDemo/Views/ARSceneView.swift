import ARKit
import AVFAudio
import Combine
import RealityKit
import SwiftUI
import UIKit

@MainActor
struct ARSceneView: UIViewRepresentable {
    let engine: ScenarioEngine

    @Binding var alertText: String
    @Binding var alertLevel: LiveMRAlertLevel
    @Binding var nearestDistance: Float?
    @Binding var statusText: String

    let resetToken: UUID

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(
            frame: .zero,
            cameraMode: .ar,
            automaticallyConfigureSession: false
        )

        context.coordinator.parent = self
        context.coordinator.arView = arView
        context.coordinator.lastResetToken = resetToken
        arView.session.delegate = context.coordinator

        configureSession(for: arView)
        return arView
    }

    func updateUIView(_ arView: ARView, context: Context) {
        context.coordinator.parent = self

        guard context.coordinator.lastResetToken != resetToken else {
            return
        }

        context.coordinator.lastResetToken = resetToken

        DispatchQueue.main.async {
            context.coordinator.resetDemo()
        }
    }

    static func dismantleUIView(
        _ arView: ARView,
        coordinator: Coordinator
    ) {
        coordinator.stop()
        arView.session.pause()
        coordinator.arView = nil
    }

    private func configureSession(for arView: ARView) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]

        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics.insert(.sceneDepth)
        }

        arView.session.run(
            configuration,
            options: [.resetTracking, .removeExistingAnchors]
        )

        arView.debugOptions = [.showFeaturePoints]
    }
}

extension ARSceneView {
    @MainActor
    final class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARSceneView
        weak var arView: ARView?
        var lastResetToken: UUID?

        private var demoAnchor: AnchorEntity?
        private var hasPlacedObjects = false

        private var redCubeEntity: ModelEntity?
        private var orangeCubeEntity: ModelEntity?
        private var greenSphereEntity: ModelEntity?

        private var updateSubscription: (any Cancellable)?
        private var lastProximityUpdate: TimeInterval = 0

        private let speechSynthesizer = AVSpeechSynthesizer()
        private let hapticGenerator = UINotificationFeedbackGenerator()

        private var activeObjectName: String?
        private let triggerDistance: Float = 0.8
        private let rearmDistance: Float = 1.2
        
        init(parent: ARSceneView) {
            self.parent = parent
            super.init()
            configureAudioSession()
        }

        nonisolated func session(
            _ session: ARSession,
            didAdd anchors: [ARAnchor]
        ) {
            Task { @MainActor in
                self.handlePlaneAnchors(anchors)
            }
        }

        nonisolated func session(
            _ session: ARSession,
            didUpdate anchors: [ARAnchor]
        ) {
            Task { @MainActor in
                self.handlePlaneAnchors(anchors)
            }
        }

        private func handlePlaneAnchors(_ anchors: [ARAnchor]) {
            guard !hasPlacedObjects, let arView else {
                return
            }

            guard let planeAnchor = anchors
                .compactMap({ $0 as? ARPlaneAnchor })
                .first(where: { plane in
                    plane.alignment == .horizontal &&
                    plane.planeExtent.width >= 2.5 &&
                    plane.planeExtent.height >= 2.0
                })
            else {
                setStatus(
                    "Scanning environment…\nMove the iPhone slowly and point it at the floor."
                )
                return
            }

            setStatus("Horizontal surface detected…")
            placeDemoObjects(on: planeAnchor, in: arView)
        }

        private func placeDemoObjects(
            on planeAnchor: ARPlaneAnchor,
            in arView: ARView
        ) {
            guard !hasPlacedObjects else {
                return
            }

            hasPlacedObjects = true

            let redSize: Float = 0.14
            let orangeSize: Float = 0.12
            let greenRadius: Float = 0.07

            let redCube = makeBox(
                size: redSize,
                color: .red,
                name: "critical-risk"
            )

            let orangeCube = makeBox(
                size: orangeSize,
                color: .orange,
                name: "obstacle"
            )

            let greenSphere = makeSphere(
                radius: greenRadius,
                color: .green,
                name: "destination"
            )

            /*
             The anchor follows the detected horizontal plane.
             Object positions are local to that plane.
             */
            let anchor = AnchorEntity(anchor: planeAnchor)

            let centerX = planeAnchor.center.x
            let centerZ = planeAnchor.center.z

            /*
             A small downward offset helps prevent the objects
             from appearing to float because of plane-estimation noise.
             */
            let floorCorrection: Float = 0.01

            redCube.position = [
                centerX - 1.2,
                (redSize / 2) - floorCorrection,
                centerZ - 0.4
            ]

            orangeCube.position = [
                centerX + 1.2,
                (orangeSize / 2) - floorCorrection,
                centerZ - 0.4
            ]

            greenSphere.position = [
                centerX,
                greenRadius - floorCorrection,
                centerZ + 1.4
            ]

            redCubeEntity = redCube
            orangeCubeEntity = orangeCube
            greenSphereEntity = greenSphere

            anchor.addChild(redCube)
            anchor.addChild(orangeCube)
            anchor.addChild(greenSphere)

            arView.scene.addAnchor(anchor)

            demoAnchor = anchor

            startProximityMonitoring(in: arView)

            setStatus(
                "Demo ready.\nWalk slowly toward the virtual objects."
            )

            setAlert(
                text: "Monitoring proximity",
                level: .ready,
                distance: nil
            )
        }
        
        private func makeBox(
            size: Float,
            color: UIColor,
            name: String
        ) -> ModelEntity {
            let entity = ModelEntity(
                mesh: .generateBox(size: size, cornerRadius: 0.02),
                materials: [SimpleMaterial(color: color, isMetallic: false)]
            )
            entity.name = name
            return entity
        }

        private func makeSphere(
            radius: Float,
            color: UIColor,
            name: String
        ) -> ModelEntity {
            let entity = ModelEntity(
                mesh: .generateSphere(radius: radius),
                materials: [SimpleMaterial(color: color, isMetallic: false)]
            )
            entity.name = name
            return entity
        }

        private func startProximityMonitoring(in arView: ARView) {
            configureAudioSession()
            updateSubscription?.cancel()

            updateSubscription = arView.scene.subscribe(
                to: SceneEvents.Update.self
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.updateProximity()
                }
            }
        }

        private func updateProximity() {
            let currentTime = ProcessInfo.processInfo.systemUptime

            guard currentTime - lastProximityUpdate >= 0.15 else {
                return
            }

            lastProximityUpdate = currentTime

            guard let arView else {
                return
            }

            let cameraPosition = arView.cameraTransform.translation

            var nearestObject: ObjectDistance?

            evaluateObject(
                redCubeEntity,
                name: "Critical risk",
                level: .critical,
                cameraPosition: cameraPosition,
                nearestObject: &nearestObject
            )

            evaluateObject(
                orangeCubeEntity,
                name: "Obstacle",
                level: .warning,
                cameraPosition: cameraPosition,
                nearestObject: &nearestObject
            )

            evaluateObject(
                greenSphereEntity,
                name: "Destination",
                level: .destination,
                cameraPosition: cameraPosition,
                nearestObject: &nearestObject
            )

            guard let nearestObject else {
                return
            }

            updateAlert(for: nearestObject)
        }

        private typealias ObjectDistance = (
            name: String,
            distance: Float,
            level: LiveMRAlertLevel
        )

        private func evaluateObject(
            _ entity: ModelEntity?,
            name: String,
            level: LiveMRAlertLevel,
            cameraPosition: SIMD3<Float>,
            nearestObject: inout ObjectDistance?
        ) {
            guard let entity else {
                return
            }

            let objectPosition = entity.position(relativeTo: nil)

            let horizontalCameraPosition = SIMD2<Float>(
                cameraPosition.x,
                cameraPosition.z
            )

            let horizontalObjectPosition = SIMD2<Float>(
                objectPosition.x,
                objectPosition.z
            )

            let distance = simd_distance(
                horizontalCameraPosition,
                horizontalObjectPosition
            )

            if nearestObject == nil || distance < nearestObject!.distance {
                nearestObject = (name, distance, level)
            }
        }

        private func updateAlert(for object: ObjectDistance) {
            let roundedDistance = (object.distance * 10).rounded() / 10
            let text: String
            let level: LiveMRAlertLevel

            if object.distance > rearmDistance {
                if activeObjectName == object.name {
                    activeObjectName = nil
                }

                text = "Monitoring proximity"
                level = .ready

            } else if object.distance > triggerDistance {
                text = "\(object.name) ahead"
                level = .advisory

            } else {
                level = object.level

                switch object.level {
                case .critical:
                    text = "Stop immediately.\nCritical risk ahead."

                case .warning:
                    text = "Obstacle ahead.\nReduce speed."

                case .destination:
                    text = "Destination reached.\nTarget location detected."

                default:
                    text = object.name
                }

                triggerAccessibleFeedbackIfNeeded(
                    objectName: object.name,
                    message: text,
                    level: object.level,
                    distance: object.distance
                )
            }

            setAlert(
                text: text,
                level: level,
                distance: roundedDistance
            )
        }

        private func triggerAccessibleFeedbackIfNeeded(
            objectName: String,
            message: String,
            level: LiveMRAlertLevel,
            distance: Float
        ) {
            guard activeObjectName != objectName else {
                return
            }

            activeObjectName = objectName

            speak(message)
            playHaptic(for: level)

            let event = makeNavigationEvent(
                objectName: objectName,
                message: message,
                level: level,
                distance: distance
            )

            parent.engine.recordLiveMREvent(event)
        }

        private func makeNavigationEvent(
            objectName: String,
            message: String,
            level: LiveMRAlertLevel,
            distance: Float
        ) -> NavigationEvent {
            let entityType: NavigationEntityType
            let priority: NavigationPriority
            let audioFamily: AudioCueFamily
            let hapticFamily: HapticCueFamily
            let expectedResponse: String

            switch level {
            case .critical:
                entityType = .riskZone
                priority = .critical
                audioFamily = .safety
                hapticFamily = .safety
                expectedResponse = "Stop immediately"

            case .warning:
                entityType = .obstacle
                priority = .high
                audioFamily = .obstacle
                hapticFamily = .obstacle
                expectedResponse = "Reduce speed and avoid the obstacle"

            case .destination:
                entityType = .destination
                priority = .medium
                audioFamily = .destination
                hapticFamily = .destination
                expectedResponse = "Confirm arrival"

            default:
                entityType = .navigationNode
                priority = .low
                audioFamily = .context
                hapticFamily = .context
                expectedResponse = "Continue monitoring"
            }

            let normalizedEntityId = objectName
                .lowercased()
                .replacingOccurrences(of: " ", with: "-")

            return NavigationEvent(
                id: "live-mr-\(UUID().uuidString)",
                entityId: normalizedEntityId,
                entityType: entityType,
                title: objectName,
                instruction: message.replacingOccurrences(
                    of: "\n",
                    with: " "
                ),
                direction: nil,
                priority: priority,
                audioCueFamily: audioFamily,
                hapticCueFamily: hapticFamily,
                distanceMeters: Double(distance),
                semanticDescription: """
                Live mixed-reality proximity event generated from \
                a virtual navigation object.
                """,
                expectedResponse: expectedResponse,
                userResponse: .pending
            )
        }

        private func speak(_ message: String) {
            speechSynthesizer.stopSpeaking(at: .immediate)

            let utterance = AVSpeechUtterance(
                string: message.replacingOccurrences(of: "\n", with: " ")
            )
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.48
            utterance.volume = 1

            speechSynthesizer.speak(utterance)
        }

        private func playHaptic(for level: LiveMRAlertLevel) {
            hapticGenerator.prepare()

            switch level {
            case .critical:
                hapticGenerator.notificationOccurred(.error)
            case .warning:
                hapticGenerator.notificationOccurred(.warning)
            case .destination:
                hapticGenerator.notificationOccurred(.success)
            default:
                break
            }
        }

        func resetDemo() {
            guard let arView else {
                return
            }

            stop()
            arView.session.pause()
            arView.scene.anchors.removeAll()

            demoAnchor = nil
            hasPlacedObjects = false
            redCubeEntity = nil
            orangeCubeEntity = nil
            greenSphereEntity = nil
            activeObjectName = nil
            lastProximityUpdate = 0

            setStatus(
                "Scanning environment…\nMove the iPhone slowly and point it at the floor."
            )
            setAlert(
                text: "Scanning environment",
                level: .scanning,
                distance: nil
            )

            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal]

            if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
                configuration.frameSemantics.insert(.sceneDepth)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                arView.session.run(
                    configuration,
                    options: [.resetTracking, .removeExistingAnchors]
                )
            }
        }

        private func configureAudioSession() {
            do {
                let audioSession = AVAudioSession.sharedInstance()

                try audioSession.setCategory(
                    .playback,
                    mode: .spokenAudio,
                    options: [.duckOthers]
                )

                try audioSession.setActive(true)
            } catch {
                print("Audio session configuration failed: \(error)")
            }
        }
        
        func stop() {
            updateSubscription?.cancel()
            updateSubscription = nil
            speechSynthesizer.stopSpeaking(at: .immediate)
        }

        private func setStatus(_ text: String) {
            guard parent.statusText != text else {
                return
            }

            DispatchQueue.main.async {
                self.parent.statusText = text
            }
        }

        private func setAlert(
            text: String,
            level: LiveMRAlertLevel,
            distance: Float?
        ) {
            DispatchQueue.main.async {
                if self.parent.alertText != text {
                    self.parent.alertText = text
                }
                if self.parent.alertLevel != level {
                    self.parent.alertLevel = level
                }
                if self.parent.nearestDistance != distance {
                    self.parent.nearestDistance = distance
                }
            }
        }
    }
}

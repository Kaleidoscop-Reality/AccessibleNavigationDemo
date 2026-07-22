//
//  ARSceneView.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 22/7/26.
//
//

import ARKit
import Combine
import RealityKit
import SwiftUI

@MainActor
struct ARSceneView: UIViewRepresentable {
    
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

    func updateUIView(
        _ arView: ARView,
        context: Context
    ) {
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
        arView.session.pause()
        coordinator.arView = nil
    }

    private func configureSession(for arView: ARView) {
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = [.horizontal]

        if ARWorldTrackingConfiguration.supportsFrameSemantics(
            .sceneDepth
        ) {
            configuration.frameSemantics.insert(.sceneDepth)
        }

        arView.session.run(
            configuration,
            options: [
                .resetTracking,
                .removeExistingAnchors
            ]
        )

        arView.debugOptions = [
            .showFeaturePoints
        ]
    }
}

// MARK: - Coordinator

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
        
        
        init(parent: ARSceneView) {
            self.parent = parent
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

        private func handlePlaneAnchors(
            _ anchors: [ARAnchor]
        ) {
            guard hasPlacedObjects == false else {
                return
            }

            guard let arView else {
                return
            }

            guard let planeAnchor = anchors
                .compactMap({ $0 as? ARPlaneAnchor })
                .first(where: { plane in
                    plane.alignment == .horizontal &&
                    plane.planeExtent.width >= 2.0 &&
                    plane.planeExtent.height >= 1.5
                })
            else {
                parent.statusText = """
                Scanning environment…
                Move the iPhone slowly and point it at the floor.
                """
                return
            }

            parent.statusText = "Horizontal surface detected…"

            placeDemoObjects(
                on: planeAnchor,
                in: arView
            )
        }

        private func placeDemoObjects(
            on planeAnchor: ARPlaneAnchor,
            in arView: ARView
        ) {
            guard hasPlacedObjects == false else {
                return
            }

            hasPlacedObjects = true

            let anchor = AnchorEntity(anchor: planeAnchor)

            let redSize: Float = 0.16
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
             ARPlaneAnchor.center indicates the actual center
             of the detected surface relative to its anchor.
             */
            let centerX = planeAnchor.center.x
            let centerZ = planeAnchor.center.z

            redCube.position = [
                centerX - 0.65,
                redSize / 2,
                centerZ - 0.35
            ]

            orangeCube.position = [
                centerX + 0.65,
                orangeSize / 2,
                centerZ - 0.35
            ]

            greenSphere.position = [
                centerX,
                greenRadius,
                centerZ + 0.45
            ]
            
            redCubeEntity = redCube
            orangeCubeEntity = orangeCube
            greenSphereEntity = greenSphere

            anchor.addChild(redCube)
            anchor.addChild(orangeCube)
            anchor.addChild(greenSphere)

            arView.scene.addAnchor(anchor)
            startProximityMonitoring(in: arView)
            demoAnchor = anchor

            parent.statusText = """
            Demo ready.
            Walk slowly toward the virtual objects.
            """
        }

        private func makeBox(
            size: Float,
            color: UIColor,
            name: String
        ) -> ModelEntity {
            let mesh = MeshResource.generateBox(
                size: size,
                cornerRadius: 0.025
            )

            let material = SimpleMaterial(
                color: color,
                isMetallic: false
            )

            let entity = ModelEntity(
                mesh: mesh,
                materials: [material]
            )

            entity.name = name

            return entity
        }

        private func makeSphere(
            radius: Float,
            color: UIColor,
            name: String
        ) -> ModelEntity {
            let mesh = MeshResource.generateSphere(
                radius: radius
            )

            let material = SimpleMaterial(
                color: color,
                isMetallic: false
            )

            let entity = ModelEntity(
                mesh: mesh,
                materials: [material]
            )

            entity.name = name

            return entity
        }
        
        private func startProximityMonitoring(
            in arView: ARView
        ) {
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

            var nearestObject: (
                name: String,
                distance: Float,
                level: LiveMRAlertLevel
            )?

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

            let roundedDistance =
                (nearestObject.distance * 10).rounded() / 10

            if parent.nearestDistance != roundedDistance {
                parent.nearestDistance = roundedDistance
            }

            updateAlert(
                objectName: nearestObject.name,
                distance: nearestObject.distance,
                objectLevel: nearestObject.level
            )
        }

        private func evaluateObject(
            _ entity: ModelEntity?,
            name: String,
            level: LiveMRAlertLevel,
            cameraPosition: SIMD3<Float>,
            nearestObject: inout (
                name: String,
                distance: Float,
                level: LiveMRAlertLevel
            )?
        ) {
            guard let entity else {
                return
            }

            let objectPosition = entity.position(
                relativeTo: nil
            )

            let distance = simd_distance(
                cameraPosition,
                objectPosition
            )

            if nearestObject == nil ||
                distance < nearestObject!.distance {
                nearestObject = (
                    name,
                    distance,
                    level
                )
            }
        }

        private func updateAlert(
            objectName: String,
            distance: Float,
            objectLevel: LiveMRAlertLevel
        ) {
            let newText: String
            let newLevel: LiveMRAlertLevel

            if distance > 3.0 {
                newText = "Monitoring proximity"
                newLevel = .ready
            } else if distance > 1.5 {
                newText = "\(objectName) ahead"
                newLevel = .advisory
            } else {
                switch objectLevel {
                case .critical:
                    newText = """
                    Stop immediately.
                    Critical risk ahead.
                    """

                case .warning:
                    newText = """
                    Obstacle ahead.
                    Reduce speed.
                    """

                case .destination:
                    newText = """
                    Destination reached.
                    Target location detected.
                    """

                default:
                    newText = objectName
                }

                newLevel = objectLevel
            }

            if parent.alertText != newText {
                parent.alertText = newText
            }

            if parent.alertLevel != newLevel {
                parent.alertLevel = newLevel
            }
        }

        func resetDemo() {
            guard let arView else {
                return
            }

            arView.session.pause()

            if let demoAnchor {
                arView.scene.removeAnchor(demoAnchor)
            }

            arView.scene.anchors.removeAll()

            demoAnchor = nil
            hasPlacedObjects = false

            redCubeEntity = nil
            orangeCubeEntity = nil
            greenSphereEntity = nil

            updateSubscription?.cancel()
            updateSubscription = nil
            
            let scanningMessage = """
            Scanning environment…
            Move the iPhone slowly and point it at the floor.
            """

            DispatchQueue.main.async {
                self.parent.statusText = scanningMessage
                self.parent.alertText = "Scanning environment"
                self.parent.alertLevel = .scanning
                self.parent.nearestDistance = nil
            }

            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal]

            if ARWorldTrackingConfiguration.supportsFrameSemantics(
                .sceneDepth
            ) {
                configuration.frameSemantics.insert(.sceneDepth)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                arView.session.run(
                    configuration,
                    options: [
                        .resetTracking,
                        .removeExistingAnchors
                    ]
                )
            }
        }
    }
}

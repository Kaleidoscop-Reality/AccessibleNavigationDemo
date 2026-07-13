//
//  HapticService.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import CoreHaptics
import Foundation
import Observation
import UIKit

@MainActor
@Observable
final class HapticService {

    private var engine: CHHapticEngine?

    private(set) var supportsHaptics: Bool
    private(set) var isEngineRunning = false
    private(set) var lastPlayedPattern: HapticPattern?
    private(set) var lastErrorMessage: String?

    var intensity: Float = 1.0

    init() {
        supportsHaptics = CHHapticEngine
            .capabilitiesForHardware()
            .supportsHaptics

        prepareEngine()
    }

    func play(
        family: HapticCueFamily,
        direction: NavigationDirection? = nil,
        priority: NavigationPriority
    ) {
        let pattern = HapticPattern(
            family: family,
            direction: direction
        )

        guard supportsHaptics else {
            playFallback(for: pattern)
            return
        }

        do {
            try ensureEngineRunning()

            let events = makeEvents(
                for: pattern,
                priority: priority
            )

            let hapticPattern = try CHHapticPattern(
                events: events,
                parameters: []
            )

            guard let engine else {
                return
            }

            let player = try engine.makePlayer(
                with: hapticPattern
            )

            try player.start(atTime: CHHapticTimeImmediate)

            lastPlayedPattern = pattern
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
            playFallback(for: pattern)
        }
    }

    func repeatLastPattern(
        priority: NavigationPriority = .medium
    ) {
        guard let lastPlayedPattern else {
            return
        }

        play(
            pattern: lastPlayedPattern,
            priority: priority
        )
    }

    func stop() {
        guard let engine else {
            isEngineRunning = false
            return
        }

        engine.stop { [weak self] error in
            let errorMessage = error?.localizedDescription

            Task { @MainActor [weak self] in
                self?.isEngineRunning = false

                if let errorMessage {
                    self?.lastErrorMessage = errorMessage
                }
            }
        }
    }

    private func play(
        pattern: HapticPattern,
        priority: NavigationPriority
    ) {
        guard supportsHaptics else {
            playFallback(for: pattern)
            return
        }

        do {
            try ensureEngineRunning()

            let events = makeEvents(
                for: pattern,
                priority: priority
            )

            let hapticPattern = try CHHapticPattern(
                events: events,
                parameters: []
            )

            guard let engine else {
                return
            }

            let player = try engine.makePlayer(
                with: hapticPattern
            )

            try player.start(atTime: CHHapticTimeImmediate)

            lastPlayedPattern = pattern
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
            playFallback(for: pattern)
        }
    }

    private func prepareEngine() {
        guard supportsHaptics else {
            return
        }

        do {
            let engine = try CHHapticEngine()

            engine.isAutoShutdownEnabled = true

            engine.stoppedHandler = { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.isEngineRunning = false
                }
            }

            engine.resetHandler = { [weak self] in
                Task { @MainActor [weak self] in
                    self?.restartEngineAfterReset()
                }
            }

            self.engine = engine

            try engine.start()
            isEngineRunning = true
        } catch {
            lastErrorMessage = error.localizedDescription
            isEngineRunning = false
        }
    }

    private func ensureEngineRunning() throws {
        guard let engine else {
            prepareEngine()

            guard self.engine != nil else {
                return
            }

            return
        }

        guard !isEngineRunning else {
            return
        }

        try engine.start()
        isEngineRunning = true
    }

    private func restartEngineAfterReset() {
        guard let engine else {
            return
        }

        do {
            try engine.start()
            isEngineRunning = true
            lastErrorMessage = nil
        } catch {
            isEngineRunning = false
            lastErrorMessage = error.localizedDescription
        }
    }

    private func makeEvents(
        for pattern: HapticPattern,
        priority: NavigationPriority
    ) -> [CHHapticEvent] {
        let adjustedIntensity = intensityForPriority(priority)

        switch pattern {
        case .continueStraight:
            return [
                transient(
                    time: 0,
                    intensity: adjustedIntensity * 0.5,
                    sharpness: 0.55
                )
            ]
        case .turnLeft, .turnRight:
            return [
                transient(
                    time: 0,
                    intensity: adjustedIntensity * 0.7,
                    sharpness: 0.75
                ),
                transient(
                    time: 0.16,
                    intensity: adjustedIntensity * 0.7,
                    sharpness: 0.75
                )
            ]
        case .directionChange:
            return [
                transient(
                    time: 0,
                    intensity: adjustedIntensity * 0.6,
                    sharpness: 0.65
                ),
                transient(
                    time: 0.22,
                    intensity: adjustedIntensity * 0.45,
                    sharpness: 0.5
                )
            ]

        case .obstacle:
            return [
                transient(
                    time: 0,
                    intensity: adjustedIntensity * 0.75,
                    sharpness: 0.8
                ),
                transient(
                    time: 0.18,
                    intensity: adjustedIntensity * 0.9,
                    sharpness: 0.85
                )
            ]

        case .destination:
            return [
                transient(
                    time: 0,
                    intensity: adjustedIntensity * 0.45,
                    sharpness: 0.35
                ),
                transient(
                    time: 0.15,
                    intensity: adjustedIntensity * 0.6,
                    sharpness: 0.45
                ),
                transient(
                    time: 0.30,
                    intensity: adjustedIntensity * 0.8,
                    sharpness: 0.55
                )
            ]

        case .context:
            return [
                transient(
                    time: 0,
                    intensity: adjustedIntensity * 0.3,
                    sharpness: 0.25
                )
            ]

        case .safety:
            return [
                continuous(
                    time: 0,
                    duration: 0.35,
                    intensity: adjustedIntensity,
                    sharpness: 0.9
                ),
                transient(
                    time: 0.45,
                    intensity: adjustedIntensity,
                    sharpness: 1.0
                ),
                transient(
                    time: 0.62,
                    intensity: adjustedIntensity,
                    sharpness: 1.0
                )
            ]

        case .system:
            return [
                transient(
                    time: 0,
                    intensity: adjustedIntensity * 0.65,
                    sharpness: 0.15
                ),
                transient(
                    time: 0.28,
                    intensity: adjustedIntensity * 0.65,
                    sharpness: 0.15
                )
            ]
        }
    }

    private func transient(
        time: TimeInterval,
        intensity: Float,
        sharpness: Float
    ) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(
                    parameterID: .hapticIntensity,
                    value: clamped(intensity)
                ),
                CHHapticEventParameter(
                    parameterID: .hapticSharpness,
                    value: clamped(sharpness)
                )
            ],
            relativeTime: time
        )
    }

    private func continuous(
        time: TimeInterval,
        duration: TimeInterval,
        intensity: Float,
        sharpness: Float
    ) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(
                    parameterID: .hapticIntensity,
                    value: clamped(intensity)
                ),
                CHHapticEventParameter(
                    parameterID: .hapticSharpness,
                    value: clamped(sharpness)
                )
            ],
            relativeTime: time,
            duration: duration
        )
    }

    private func intensityForPriority(
        _ priority: NavigationPriority
    ) -> Float {
        let priorityScale: Float

        switch priority {
        case .informative:
            priorityScale = 0.35
        case .low:
            priorityScale = 0.5
        case .medium:
            priorityScale = 0.7
        case .high:
            priorityScale = 0.9
        case .critical:
            priorityScale = 1.0
        }

        return clamped(intensity * priorityScale)
    }

    private func clamped(
        _ value: Float
    ) -> Float {
        min(max(value, 0), 1)
    }

    private func playFallback(
        for pattern: HapticPattern
    ) {
        let generator: UINotificationFeedbackGenerator

        switch pattern {
        case .safety, .obstacle:
            generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.warning)

        case .system:
            generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.error)

        case .destination:
            generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)

        case .continueStraight,
             .turnLeft,
             .turnRight,
             .directionChange,
             .context:
            let impact = UIImpactFeedbackGenerator(
                style: .medium
            )

            impact.prepare()
            impact.impactOccurred()
            return
        }
    }
}

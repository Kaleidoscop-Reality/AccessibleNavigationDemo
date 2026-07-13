//
//  FallbackResolver.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

enum FallbackModality: String, Codable, CaseIterable, Identifiable {
    case audio
    case haptics
    case visual
    case unavailable

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .audio:
            "Audio"
        case .haptics:
            "Haptics"
        case .visual:
            "Visual"
        case .unavailable:
            "Unavailable"
        }
    }
}

struct FallbackResolution: Codable, Hashable {

    let shouldDeliverEvent: Bool

    let deliverAudio: Bool
    let deliverHaptics: Bool
    let deliverVisual: Bool
    let useSpatialAudio: Bool

    let fallbackApplied: Bool
    let fallbackModality: FallbackModality?

    let isSafe: Bool
    let reason: String
}

struct FallbackResolver {

    func resolve(
        event: NavigationEvent,
        preferenceDecision: PreferenceDeliveryDecision,
        capabilities: DeviceCapabilities
    ) -> FallbackResolution {

        guard preferenceDecision.shouldDeliverEvent else {
            return FallbackResolution(
                shouldDeliverEvent: false,
                deliverAudio: false,
                deliverHaptics: false,
                deliverVisual: false,
                useSpatialAudio: false,
                fallbackApplied: false,
                fallbackModality: nil,
                isSafe: event.priority != .critical,
                reason: preferenceDecision.reason
            )
        }

        let preferredAudio =
            preferenceDecision.shouldDeliverAudio &&
            capabilities.supportsSpeechOutput

        let preferredHaptics =
            preferenceDecision.shouldDeliverHaptics &&
            capabilities.supportsHaptics

        let visualAvailable =
            capabilities.supportsVisualOutput

        let spatialAudioAvailable =
            preferenceDecision.shouldUseSpatialAudio &&
            preferredAudio &&
            capabilities.supportsSpatialAudio

        if preferredAudio || preferredHaptics {
            return FallbackResolution(
                shouldDeliverEvent: true,
                deliverAudio: preferredAudio,
                deliverHaptics: preferredHaptics,
                deliverVisual: visualAvailable,
                useSpatialAudio: spatialAudioAvailable,
                fallbackApplied: false,
                fallbackModality: nil,
                isSafe: true,
                reason: preferenceDecision.reason
            )
        }

        if event.priority != .critical {
            if visualAvailable {
                return FallbackResolution(
                    shouldDeliverEvent: true,
                    deliverAudio: false,
                    deliverHaptics: false,
                    deliverVisual: true,
                    useSpatialAudio: false,
                    fallbackApplied: true,
                    fallbackModality: .visual,
                    isSafe: true,
                    reason: """
                    Visual output was used while respecting the user's \
                    disabled audio and haptic preferences.
                    """
                )
            }

            return FallbackResolution(
                shouldDeliverEvent: true,
                deliverAudio: false,
                deliverHaptics: false,
                deliverVisual: false,
                useSpatialAudio: false,
                fallbackApplied: true,
                fallbackModality: .unavailable,
                isSafe: true,
                reason: """
                No enabled output modality is available for this \
                non-critical event.
                """
            )
        }

        if capabilities.supportsSpeechOutput {
            return FallbackResolution(
                shouldDeliverEvent: true,
                deliverAudio: true,
                deliverHaptics: false,
                deliverVisual: visualAvailable,
                useSpatialAudio: false,
                fallbackApplied: true,
                fallbackModality: .audio,
                isSafe: true,
                reason: """
                Audio was forced as a safety fallback for a critical \
                navigation event.
                """
            )
        }

        if capabilities.supportsHaptics {
            return FallbackResolution(
                shouldDeliverEvent: true,
                deliverAudio: false,
                deliverHaptics: true,
                deliverVisual: visualAvailable,
                useSpatialAudio: false,
                fallbackApplied: true,
                fallbackModality: .haptics,
                isSafe: true,
                reason: """
                Haptics were forced as a safety fallback for a critical \
                navigation event.
                """
            )
        }

        if visualAvailable {
            return FallbackResolution(
                shouldDeliverEvent: true,
                deliverAudio: false,
                deliverHaptics: false,
                deliverVisual: true,
                useSpatialAudio: false,
                fallbackApplied: true,
                fallbackModality: .visual,
                isSafe: true,
                reason: """
                Visual output was used as the only available fallback \
                for a critical navigation event.
                """
            )
        }

        return FallbackResolution(
            shouldDeliverEvent: true,
            deliverAudio: false,
            deliverHaptics: false,
            deliverVisual: false,
            useSpatialAudio: false,
            fallbackApplied: true,
            fallbackModality: .unavailable,
            isSafe: false,
            reason: """
            No accessible output modality is available for the critical \
            event. Delivery cannot be considered safe.
            """
        )
    }
}

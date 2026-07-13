//
//  PreferenceAdapter.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

struct PreferenceDeliveryDecision: Hashable {

    let shouldDeliverEvent: Bool
    let shouldDeliverAudio: Bool
    let shouldDeliverHaptics: Bool
    let shouldUseSpatialAudio: Bool

    let reason: String
}

@MainActor
final class PreferenceAdapter {

    func apply(
        profile: UserPreferenceProfile,
        to speechService: SpeechService,
        hapticService: HapticService
    ) {
        speechService.volume = clamped(profile.speechVolume)
        speechService.rate = clampedSpeechRate(
            profile.speechRate
        )

        hapticService.intensity = clamped(
            profile.hapticIntensity
        )
    }

    func deliveryDecision(
        for event: NavigationEvent,
        profile: UserPreferenceProfile,
        capabilities: DeviceCapabilities
    ) -> PreferenceDeliveryDecision {

        let shouldDeliverEvent = shouldDeliver(
            event: event,
            profile: profile
        )

        guard shouldDeliverEvent else {
            return PreferenceDeliveryDecision(
                shouldDeliverEvent: false,
                shouldDeliverAudio: false,
                shouldDeliverHaptics: false,
                shouldUseSpatialAudio: false,
                reason: """
                The event was filtered by the active user \
                preference profile.
                """
            )
        }

        let audioAvailable =
            profile.audioEnabled &&
            capabilities.supportsSpeechOutput

        let hapticsAvailable =
            profile.hapticsEnabled &&
            capabilities.supportsHaptics

        let spatialAudioAvailable =
            audioAvailable &&
            profile.spatialAudioEnabled &&
            capabilities.supportsSpatialAudio

        return PreferenceDeliveryDecision(
            shouldDeliverEvent: true,
            shouldDeliverAudio: audioAvailable,
            shouldDeliverHaptics: hapticsAvailable,
            shouldUseSpatialAudio: spatialAudioAvailable,
            reason: decisionReason(
                event: event,
                audioAvailable: audioAvailable,
                hapticsAvailable: hapticsAvailable
            )
        )
    }

    private func shouldDeliver(
        event: NavigationEvent,
        profile: UserPreferenceProfile
    ) -> Bool {

        if event.priority == .critical {
            return true
        }

        if event.priority < profile.minimumPriority {
            return false
        }

        if event.entityType == .pointOfInterest,
           !profile.pointOfInterestEventsEnabled {
            return false
        }

        if event.audioCueFamily == .context,
           !profile.contextualEventsEnabled {
            return false
        }

        return true
    }

    private func decisionReason(
        event: NavigationEvent,
        audioAvailable: Bool,
        hapticsAvailable: Bool
    ) -> String {

        if event.priority == .critical,
           !audioAvailable,
           !hapticsAvailable {
            return """
            Critical event accepted, but no preferred output \
            modality is currently available.
            """
        }

        if audioAvailable && hapticsAvailable {
            return "Audio and haptic delivery are available."
        }

        if audioAvailable {
            return "Audio delivery is available."
        }

        if hapticsAvailable {
            return "Haptic delivery is available."
        }

        return """
        The event is accepted, but the selected output \
        modalities are unavailable.
        """
    }

    private func clamped(
        _ value: Float
    ) -> Float {
        min(max(value, 0), 1)
    }

    private func clampedSpeechRate(
        _ value: Float
    ) -> Float {
        min(max(value, 0.1), 0.6)
    }
}

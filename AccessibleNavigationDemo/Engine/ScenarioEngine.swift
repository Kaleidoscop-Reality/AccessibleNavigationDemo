//
//  ScenarioEngine.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class ScenarioEngine {

    private(set) var events: [NavigationEvent]
    private(set) var state: ScenarioState

    private(set) var activeProfile: UserPreferenceProfile
    private(set) var deviceCapabilities: DeviceCapabilities
    private(set) var lastFallbackResolution: FallbackResolution?

    let logger: EventLogService
    let speechService: SpeechService
    let hapticService: HapticService

    let preferenceAdapter: PreferenceAdapter
    let fallbackResolver: FallbackResolver

    init() {
        let speechService = SpeechService()
        let hapticService = HapticService()
        let preferenceAdapter = PreferenceAdapter()

        self.events = NavigationEvent.sampleEvents
        self.state = .initial

        self.logger = EventLogService()
        self.speechService = speechService
        self.hapticService = hapticService

        self.activeProfile = .defaultProfile

        self.deviceCapabilities = DeviceCapabilities(
            supportsSpeechOutput: true,
            supportsHaptics: hapticService.supportsHaptics,
            supportsSpatialAudio: false,
            supportsVisualOutput: true,
            supportsVoiceOver: true
        )

        self.preferenceAdapter = preferenceAdapter
        self.fallbackResolver = FallbackResolver()

        preferenceAdapter.apply(
            profile: activeProfile,
            to: speechService,
            hapticService: hapticService
        )
    }

    init(
        events: [NavigationEvent],
        logger: EventLogService,
        speechService: SpeechService,
        hapticService: HapticService
    ) {
        let preferenceAdapter = PreferenceAdapter()

        self.events = events
        self.state = .initial

        self.logger = logger
        self.speechService = speechService
        self.hapticService = hapticService

        self.activeProfile = .defaultProfile

        self.deviceCapabilities = DeviceCapabilities(
            supportsSpeechOutput: true,
            supportsHaptics: hapticService.supportsHaptics,
            supportsSpatialAudio: false,
            supportsVisualOutput: true,
            supportsVoiceOver: true
        )

        self.preferenceAdapter = preferenceAdapter
        self.fallbackResolver = FallbackResolver()

        preferenceAdapter.apply(
            profile: activeProfile,
            to: speechService,
            hapticService: hapticService
        )
    }

    init(
        events: [NavigationEvent],
        logger: EventLogService,
        speechService: SpeechService,
        hapticService: HapticService,
        activeProfile: UserPreferenceProfile,
        deviceCapabilities: DeviceCapabilities,
        preferenceAdapter: PreferenceAdapter,
        fallbackResolver: FallbackResolver
    ) {
        self.events = events
        self.state = .initial

        self.logger = logger
        self.speechService = speechService
        self.hapticService = hapticService

        self.activeProfile = activeProfile
        self.deviceCapabilities = deviceCapabilities

        self.preferenceAdapter = preferenceAdapter
        self.fallbackResolver = fallbackResolver

        preferenceAdapter.apply(
            profile: activeProfile,
            to: speechService,
            hapticService: hapticService
        )
    }

    var currentEvent: NavigationEvent? {
        guard events.indices.contains(state.currentIndex) else {
            return nil
        }

        return events[state.currentIndex]
    }

    var currentPosition: Int {
        guard !events.isEmpty else {
            return 0
        }

        return state.currentIndex + 1
    }

    var totalEvents: Int {
        events.count
    }

    var progress: Double {
        guard !events.isEmpty else {
            return 0
        }

        return Double(currentPosition) / Double(totalEvents)
    }

    var canMovePrevious: Bool {
        state.currentIndex > 0
    }

    var canMoveNext: Bool {
        state.currentIndex < events.count - 1
    }

    func updateProfile(
        _ profile: UserPreferenceProfile
    ) {
        activeProfile = profile

        preferenceAdapter.apply(
            profile: profile,
            to: speechService,
            hapticService: hapticService
        )

        logger.record(
            action: .preferenceProfileChanged,
            event: currentEvent,
            message: """
            Active preference profile changed to \
            \(profile.name).
            """
        )
    }

    func updateDeviceCapabilities(
        _ capabilities: DeviceCapabilities
    ) {
        deviceCapabilities = capabilities

        logger.record(
            action: .deviceCapabilitiesUpdated,
            event: currentEvent,
            message: """
            Device capabilities were updated. \
            Speech: \(capabilities.supportsSpeechOutput), \
            haptics: \(capabilities.supportsHaptics), \
            visual: \(capabilities.supportsVisualOutput).
            """
        )
    }

    func start() {
        guard !events.isEmpty else {
            state.status = .completed

            logger.record(
                action: .scenarioCompleted,
                message: "The scenario contains no events."
            )

            return
        }

        state.currentIndex = 0
        state.status = .running

        logger.record(
            action: .scenarioStarted,
            message: """
            The accessible navigation scenario started using \
            the \(activeProfile.name) profile.
            """
        )

        presentCurrentEvent()
    }

    func moveToNextEvent() {
        guard state.status == .running else {
            return
        }

        guard canMoveNext else {
            completeScenario()
            return
        }

        state.currentIndex += 1
        presentCurrentEvent()
    }

    func moveToPreviousEvent() {
        guard state.status == .running ||
                state.status == .paused else {
            return
        }

        guard canMovePrevious else {
            return
        }

        let sourceEvent = currentEvent

        logger.record(
            action: .previousEventRequested,
            event: sourceEvent,
            message: "The previous navigation event was requested."
        )

        state.currentIndex -= 1

        if state.status == .running {
            presentCurrentEvent()
        }
    }

    func pause() {
        guard state.status == .running else {
            return
        }

        state.status = .paused
        speechService.pause()

        logger.record(
            action: .scenarioPaused,
            event: currentEvent,
            message: "The navigation scenario was paused."
        )
    }

    func resume() {
        guard state.status == .paused else {
            return
        }

        state.status = .running
        speechService.resume()

        logger.record(
            action: .scenarioResumed,
            event: currentEvent,
            message: "The navigation scenario resumed."
        )
    }

    func acknowledgeCurrentEvent() {
        guard state.status == .running,
              let event = currentEvent else {
            return
        }

        updateCurrentResponse(.acknowledged)

        logger.record(
            action: .eventAcknowledged,
            event: event,
            message: "The user acknowledged \(event.title)."
        )
    }

    func repeatCurrentEvent() {
        guard state.status == .running,
              let event = currentEvent else {
            return
        }

        updateCurrentResponse(.repeated)

        logger.record(
            action: .eventRepeated,
            event: event,
            message: """
            The user requested repetition of \
            \(event.title).
            """
        )

        deliver(event)
    }

    func completeCurrentEvent() {
        guard state.status == .running,
              let event = currentEvent else {
            return
        }

        updateCurrentResponse(.completed)

        logger.record(
            action: .eventCompleted,
            event: event,
            message: """
            The event \(event.title) was marked as \
            completed.
            """
        )
    }

    func emergencyStop() {
        let event = currentEvent

        speechService.stop()
        hapticService.stop()

        updateCurrentResponse(.emergencyStop)
        state.status = .cancelled

        logger.record(
            action: .audioCueStopped,
            event: event,
            message: "Speech stopped due to emergency stop."
        )

        logger.record(
            action: .hapticCueStopped,
            event: event,
            message: """
            Haptic output stopped due to emergency stop.
            """
        )

        logger.record(
            action: .emergencyStop,
            event: event,
            message: event.map {
                """
                Emergency stop activated during \
                \($0.title).
                """
            } ?? """
            Emergency stop activated without an active event.
            """
        )
    }

    func cancel() {
        guard state.status == .running ||
                state.status == .paused else {
            return
        }

        let event = currentEvent

        speechService.stop()
        hapticService.stop()

        updateCurrentResponse(.cancelled)
        state.status = .cancelled

        logger.record(
            action: .audioCueStopped,
            event: event,
            message: """
            Speech stopped because the scenario was \
            cancelled.
            """
        )

        logger.record(
            action: .hapticCueStopped,
            event: event,
            message: """
            Haptic output stopped because the scenario was \
            cancelled.
            """
        )

        logger.record(
            action: .scenarioCancelled,
            event: event,
            message: "The navigation scenario was cancelled."
        )
    }

    func restart() {
        speechService.stop()
        hapticService.stop()

        events = events.map { event in
            var resetEvent = event
            resetEvent.userResponse = .pending
            return resetEvent
        }

        state = .initial
        lastFallbackResolution = nil

        logger.clear()

        logger.record(
            action: .scenarioRestarted,
            message: """
            The navigation scenario was reset using the \
            \(activeProfile.name) profile.
            """
        )
    }

    private func updateCurrentResponse(
        _ response: UserResponse
    ) {
        guard events.indices.contains(state.currentIndex) else {
            return
        }

        events[state.currentIndex].userResponse = response
    }

    private func presentCurrentEvent() {
        guard let event = currentEvent else {
            return
        }

        let resolution = resolveDelivery(for: event)

        guard resolution.shouldDeliverEvent else {
            logger.record(
                action: .eventFiltered,
                event: event,
                message: resolution.reason
            )

            advancePastFilteredEvent()
            return
        }

        logger.record(
            action: .eventPresented,
            event: event,
            message: """
            Presented \(event.title). \
            Audio: \(resolution.deliverAudio), \
            haptics: \(resolution.deliverHaptics), \
            visual: \(resolution.deliverVisual).
            """
        )

        recordFallback(
            resolution,
            for: event
        )

        deliver(
            event,
            using: resolution,
            repeated: false
        )
    }

    private func deliver(
        _ event: NavigationEvent
    ) {
        let resolution = resolveDelivery(for: event)

        guard resolution.shouldDeliverEvent else {
            logger.record(
                action: .eventFiltered,
                event: event,
                message: resolution.reason
            )

            return
        }

        recordFallback(
            resolution,
            for: event
        )

        deliver(
            event,
            using: resolution,
            repeated: true
        )
    }

    private func deliver(
        _ event: NavigationEvent,
        using resolution: FallbackResolution,
        repeated: Bool
    ) {
        if resolution.deliverAudio {
            speechService.speak(
                event.instruction,
                interruptCurrentSpeech: true
            )

            logger.record(
                action: repeated
                    ? .audioCueRepeated
                    : .audioCueDelivered,
                event: event,
                message: repeated
                    ? """
                    Repeated spoken instruction: \
                    \(event.instruction)
                    """
                    : """
                    Spoken instruction delivered: \
                    \(event.instruction)
                    """
            )
        }

        if resolution.deliverHaptics {
            hapticService.play(
                family: event.hapticCueFamily,
                direction: event.direction,
                priority: event.priority
            )

            logger.record(
                action: repeated
                    ? .hapticCueRepeated
                    : .hapticCueDelivered,
                event: event,
                message: repeated
                    ? """
                    Repeated haptic cue using \
                    \(event.hapticCueFamily.rawValue).
                    """
                    : """
                    Haptic cue delivered using \
                    \(event.hapticCueFamily.rawValue).
                    """
            )
        }
    }

    private func resolveDelivery(
        for event: NavigationEvent
    ) -> FallbackResolution {
        let preferenceDecision =
            preferenceAdapter.deliveryDecision(
                for: event,
                profile: activeProfile,
                capabilities: deviceCapabilities
            )

        let resolution = fallbackResolver.resolve(
            event: event,
            preferenceDecision: preferenceDecision,
            capabilities: deviceCapabilities
        )

        lastFallbackResolution = resolution

        return resolution
    }

    private func recordFallback(
        _ resolution: FallbackResolution,
        for event: NavigationEvent
    ) {
        guard resolution.fallbackApplied else {
            return
        }

        logger.record(
            action: resolution.isSafe
                ? .fallbackApplied
                : .unsafeDeliveryDetected,
            event: event,
            message: resolution.reason
        )
    }

    private func advancePastFilteredEvent() {
        guard state.status == .running else {
            return
        }

        guard canMoveNext else {
            completeScenario()
            return
        }

        state.currentIndex += 1
        presentCurrentEvent()
    }

    private func completeScenario() {
        state.status = .completed

        logger.record(
            action: .scenarioCompleted,
            event: currentEvent,
            message: "All navigation events were processed."
        )
    }
}

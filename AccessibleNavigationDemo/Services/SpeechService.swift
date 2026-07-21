//
//  SpeechService.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import AVFAudio
import Foundation
import Observation

@MainActor
@Observable
final class SpeechService: NSObject {

    private let synthesizer = AVSpeechSynthesizer()

    private(set) var isSpeaking = false
    private(set) var isPaused = false
    private(set) var lastSpokenText: String?
    private(set) var lastErrorMessage: String?

    var languageCode = "en-US"
    var rate: Float = 0.48
    var pitchMultiplier: Float = 1.0
    var volume: Float = 1.0

    override init() {
        super.init()

        synthesizer.delegate = self

        configureAudioSession()
    }

    func speak(
        _ text: String,
        interruptCurrentSpeech: Bool = true
    ) {
        let cleanText = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanText.isEmpty else {
            return
        }

        if interruptCurrentSpeech,
           synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(
            string: cleanText
        )

        utterance.voice = AVSpeechSynthesisVoice(
            language: languageCode
        )

        utterance.rate = clampedRate(rate)
        utterance.pitchMultiplier = clampedPitch(
            pitchMultiplier
        )
        utterance.volume = clampedVolume(volume)

        lastSpokenText = cleanText
        lastErrorMessage = nil
        isPaused = false

        synthesizer.speak(utterance)
    }

    func repeatLastInstruction() {
        guard let lastSpokenText else {
            return
        }

        speak(
            lastSpokenText,
            interruptCurrentSpeech: true
        )
    }

    func stop() {
        guard synthesizer.isSpeaking ||
                synthesizer.isPaused else {
            isSpeaking = false
            isPaused = false
            return
        }

        synthesizer.stopSpeaking(at: .immediate)

        isSpeaking = false
        isPaused = false
    }

    func pause() {
        guard synthesizer.isSpeaking else {
            return
        }

        let paused = synthesizer.pauseSpeaking(
            at: .word
        )

        if paused {
            isSpeaking = false
            isPaused = true
        }
    }

    func resume() {
        guard synthesizer.isPaused else {
            return
        }

        let resumed = synthesizer.continueSpeaking()

        if resumed {
            isSpeaking = true
            isPaused = false
        }
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(
                .playback,
                mode: .voicePrompt,
                options: [.duckOthers]
            )

            try session.setActive(true)

            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    private func clampedRate(
        _ value: Float
    ) -> Float {
        min(max(value, 0.1), 0.6)
    }

    private func clampedPitch(
        _ value: Float
    ) -> Float {
        min(max(value, 0.5), 2.0)
    }

    private func clampedVolume(
        _ value: Float
    ) -> Float {
        min(max(value, 0), 1)
    }
}

extension SpeechService: AVSpeechSynthesizerDelegate {

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didStart utterance: AVSpeechUtterance
    ) {
        Task { @MainActor [weak self] in
            self?.isSpeaking = true
            self?.isPaused = false
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        Task { @MainActor [weak self] in
            self?.isSpeaking = false
            self?.isPaused = false
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        Task { @MainActor [weak self] in
            self?.isSpeaking = false
            self?.isPaused = false
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didPause utterance: AVSpeechUtterance
    ) {
        Task { @MainActor [weak self] in
            self?.isSpeaking = false
            self?.isPaused = true
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didContinue utterance: AVSpeechUtterance
    ) {
        Task { @MainActor [weak self] in
            self?.isSpeaking = true
            self?.isPaused = false
        }
    }
}


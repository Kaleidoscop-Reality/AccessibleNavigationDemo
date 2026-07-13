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
final class SpeechService {

    private let synthesizer = AVSpeechSynthesizer()

    private(set) var isSpeaking = false
    private(set) var lastSpokenText: String?

    var languageCode = "en-US"
    var rate: Float = 0.48
    var pitchMultiplier: Float = 1.0
    var volume: Float = 1.0

    init() {
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
           synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(
            string: cleanText
        )

        utterance.voice = AVSpeechSynthesisVoice(
            language: languageCode
        )

        utterance.rate = rate
        utterance.pitchMultiplier = pitchMultiplier
        utterance.volume = volume

        lastSpokenText = cleanText
        isSpeaking = true

        synthesizer.speak(utterance)
    }

    func repeatLastInstruction() {
        guard let lastSpokenText else {
            return
        }

        speak(lastSpokenText)
    }

    func stop() {
        guard synthesizer.isSpeaking else {
            isSpeaking = false
            return
        }

        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    func pause() {
        guard synthesizer.isSpeaking else {
            return
        }

        synthesizer.pauseSpeaking(at: .word)
        isSpeaking = false
    }

    func resume() {
        let resumed = synthesizer.continueSpeaking()

        if resumed {
            isSpeaking = true
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
        } catch {
            print(
                "Audio session configuration failed: \(error)"
            )
        }
    }
}

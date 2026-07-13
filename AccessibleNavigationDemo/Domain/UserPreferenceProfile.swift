//
//  UserPreferenceProfile.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

enum NavigationDetailLevel: String, Codable, CaseIterable, Identifiable {
    case minimal
    case concise
    case standard
    case detailed

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .minimal:
            "Minimal"
        case .concise:
            "Concise"
        case .standard:
            "Standard"
        case .detailed:
            "Detailed"
        }
    }

    var description: String {
        switch self {
        case .minimal:
            "Only essential safety and navigation information."
        case .concise:
            "Short instructions with limited contextual information."
        case .standard:
            "Balanced navigation instructions and context."
        case .detailed:
            "Extended instructions with additional contextual information."
        }
    }
}

struct UserPreferenceProfile: Identifiable, Codable, Hashable {
    let id: String

    var name: String

    var audioEnabled: Bool
    var hapticsEnabled: Bool
    var spatialAudioEnabled: Bool

    var speechVolume: Float
    var speechRate: Float
    var hapticIntensity: Float

    var repetitionEnabled: Bool
    var automaticRepetitionCount: Int

    var detailLevel: NavigationDetailLevel

    var minimumPriority: NavigationPriority

    var contextualEventsEnabled: Bool
    var pointOfInterestEventsEnabled: Bool
    var earlyWarningsEnabled: Bool

    init(
        id: String,
        name: String,
        audioEnabled: Bool = true,
        hapticsEnabled: Bool = true,
        spatialAudioEnabled: Bool = false,
        speechVolume: Float = 1.0,
        speechRate: Float = 0.48,
        hapticIntensity: Float = 1.0,
        repetitionEnabled: Bool = true,
        automaticRepetitionCount: Int = 0,
        detailLevel: NavigationDetailLevel = .standard,
        minimumPriority: NavigationPriority = .informative,
        contextualEventsEnabled: Bool = true,
        pointOfInterestEventsEnabled: Bool = true,
        earlyWarningsEnabled: Bool = false
    ) {
        self.id = id
        self.name = name
        self.audioEnabled = audioEnabled
        self.hapticsEnabled = hapticsEnabled
        self.spatialAudioEnabled = spatialAudioEnabled
        self.speechVolume = Self.clamp(speechVolume)
        self.speechRate = Self.clampSpeechRate(speechRate)
        self.hapticIntensity = Self.clamp(hapticIntensity)
        self.repetitionEnabled = repetitionEnabled
        self.automaticRepetitionCount = max(
            automaticRepetitionCount,
            0
        )
        self.detailLevel = detailLevel
        self.minimumPriority = minimumPriority
        self.contextualEventsEnabled = contextualEventsEnabled
        self.pointOfInterestEventsEnabled = pointOfInterestEventsEnabled
        self.earlyWarningsEnabled = earlyWarningsEnabled
    }

    private static func clamp(
        _ value: Float
    ) -> Float {
        min(max(value, 0), 1)
    }

    private static func clampSpeechRate(
        _ value: Float
    ) -> Float {
        min(max(value, 0.1), 0.6)
    }
}


extension UserPreferenceProfile {

    static let audioFirst = UserPreferenceProfile(
        id: "PROFILE-AUDIO-FIRST",
        name: "Audio First",
        audioEnabled: true,
        hapticsEnabled: true,
        spatialAudioEnabled: true,
        speechVolume: 1.0,
        speechRate: 0.46,
        hapticIntensity: 0.6,
        repetitionEnabled: true,
        automaticRepetitionCount: 0,
        detailLevel: .detailed,
        minimumPriority: .informative,
        contextualEventsEnabled: true,
        pointOfInterestEventsEnabled: true,
        earlyWarningsEnabled: false
    )

    static let hapticReinforced = UserPreferenceProfile(
        id: "PROFILE-HAPTIC-REINFORCED",
        name: "Haptic Reinforced",
        audioEnabled: true,
        hapticsEnabled: true,
        spatialAudioEnabled: false,
        speechVolume: 0.85,
        speechRate: 0.5,
        hapticIntensity: 1.0,
        repetitionEnabled: true,
        automaticRepetitionCount: 0,
        detailLevel: .concise,
        minimumPriority: .low,
        contextualEventsEnabled: false,
        pointOfInterestEventsEnabled: false,
        earlyWarningsEnabled: true
    )

    static let lowCognitiveLoad = UserPreferenceProfile(
        id: "PROFILE-LOW-COGNITIVE-LOAD",
        name: "Low Cognitive Load",
        audioEnabled: true,
        hapticsEnabled: true,
        spatialAudioEnabled: false,
        speechVolume: 0.9,
        speechRate: 0.42,
        hapticIntensity: 0.75,
        repetitionEnabled: true,
        automaticRepetitionCount: 0,
        detailLevel: .minimal,
        minimumPriority: .medium,
        contextualEventsEnabled: false,
        pointOfInterestEventsEnabled: false,
        earlyWarningsEnabled: true
    )

    static let defaultProfile = audioFirst

    static let predefinedProfiles: [UserPreferenceProfile] = [
        audioFirst,
        hapticReinforced,
        lowCognitiveLoad
    ]
}

//
//  DeviceCapabilities.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

struct DeviceCapabilities: Codable, Hashable {

    var supportsSpeechOutput: Bool
    var supportsHaptics: Bool
    var supportsSpatialAudio: Bool
    var supportsVisualOutput: Bool
    var supportsVoiceOver: Bool

    init(
        supportsSpeechOutput: Bool = true,
        supportsHaptics: Bool = true,
        supportsSpatialAudio: Bool = false,
        supportsVisualOutput: Bool = true,
        supportsVoiceOver: Bool = true
    ) {
        self.supportsSpeechOutput = supportsSpeechOutput
        self.supportsHaptics = supportsHaptics
        self.supportsSpatialAudio = supportsSpatialAudio
        self.supportsVisualOutput = supportsVisualOutput
        self.supportsVoiceOver = supportsVoiceOver
    }
}

extension DeviceCapabilities {

    static let standardIPhone = DeviceCapabilities(
        supportsSpeechOutput: true,
        supportsHaptics: true,
        supportsSpatialAudio: false,
        supportsVisualOutput: true,
        supportsVoiceOver: true
    )

    static let noHaptics = DeviceCapabilities(
        supportsSpeechOutput: true,
        supportsHaptics: false,
        supportsSpatialAudio: false,
        supportsVisualOutput: true,
        supportsVoiceOver: true
    )

    static let limitedAudio = DeviceCapabilities(
        supportsSpeechOutput: false,
        supportsHaptics: true,
        supportsSpatialAudio: false,
        supportsVisualOutput: true,
        supportsVoiceOver: true
    )
}

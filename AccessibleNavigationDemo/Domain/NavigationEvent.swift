//
//  NavigationEvent.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

struct NavigationEvent: Identifiable, Codable, Hashable {
    let id: String
    let entityId: String

    let entityType: NavigationEntityType
    let title: String
    let instruction: String
    let direction: NavigationDirection?

    let priority: NavigationPriority

    let audioCueFamily: AudioCueFamily
    let hapticCueFamily: HapticCueFamily

    let distanceMeters: Double?
    let semanticDescription: String
    let expectedResponse: String

    var userResponse: UserResponse
}

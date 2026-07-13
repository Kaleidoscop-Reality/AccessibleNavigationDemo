//
//  NavigationEntityType.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

enum NavigationEntityType: String, Codable, CaseIterable, Identifiable {
    case accessibleRoute
    case navigationNode
    case decisionPoint
    case directionEvent
    case obstacle
    case landmark
    case destination
    case pointOfInterest
    case riskZone
    case accessibilityCueReference
    case userPreferenceBinding
    case systemReliabilityState

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .accessibleRoute:
            "Accessible Route"
        case .navigationNode:
            "Navigation Node"
        case .decisionPoint:
            "Decision Point"
        case .directionEvent:
            "Direction Event"
        case .obstacle:
            "Obstacle"
        case .landmark:
            "Landmark"
        case .destination:
            "Destination"
        case .pointOfInterest:
            "Point of Interest"
        case .riskZone:
            "Risk Zone"
        case .accessibilityCueReference:
            "Accessibility Cue Reference"
        case .userPreferenceBinding:
            "User Preference Binding"
        case .systemReliabilityState:
            "System Reliability State"
        }
    }
}

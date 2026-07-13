//
//  HapticPattern.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

enum HapticPattern: String, Codable, CaseIterable, Identifiable {
    case continueStraight
    case turnLeft
    case turnRight
    case directionChange
    case obstacle
    case destination
    case context
    case safety
    case system

    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .continueStraight:
            "Continue Straight"
        case .turnLeft:
            "Turn Left"
        case .turnRight:
            "Turn Right"
        case .directionChange:
            "Direction Change"
        case .obstacle:
            "Obstacle"
        case .destination:
            "Destination"
        case .context:
            "Context"
        case .safety:
            "Safety"
        case .system:
            "System"
        }
    }

    init(
        family: HapticCueFamily,
        direction: NavigationDirection? = nil
    ) {
        switch family {
        case .direction:
            switch direction {
            case .straight:
                self = .continueStraight
            case .left:
                self = .turnLeft
            case .right:
                self = .turnRight
            default:
                self = .directionChange
            }

        case .obstacle:
            self = .obstacle
        case .destination:
            self = .destination
        case .context:
            self = .context
        case .safety:
            self = .safety
        case .system:
            self = .system
        }
    }
}

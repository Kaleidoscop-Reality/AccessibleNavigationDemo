//
//  NavigationDirection.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//
import Foundation

enum NavigationDirection: String, Codable, CaseIterable, Identifiable {
    case straight
    case left
    case right
    case slightLeft
    case slightRight
    case back
    case levelChange

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .straight:
            "Straight"
        case .left:
            "Left"
        case .right:
            "Right"
        case .slightLeft:
            "Slight Left"
        case .slightRight:
            "Slight Right"
        case .back:
            "Back"
        case .levelChange:
            "Level Change"
        }
    }
}

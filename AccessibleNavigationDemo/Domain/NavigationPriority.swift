//
//  NavigationPriority.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

enum NavigationPriority: Int, Codable, CaseIterable, Comparable, Identifiable {
    case informative = 0
    case low = 1
    case medium = 2
    case high = 3
    case critical = 4

    var id: Int {
        rawValue
    }

    var code: String {
        "P\(rawValue)"
    }

    var title: String {
        switch self {
        case .informative:
            "Informative"
        case .low:
            "Low"
        case .medium:
            "Medium"
        case .high:
            "High"
        case .critical:
            "Critical"
        }
    }

    var description: String {
        switch self {
        case .informative:
            "Non-essential contextual information."
        case .low:
            "Orientation support."
        case .medium:
            "Ordinary navigation instruction."
        case .high:
            "Important warning or route decision."
        case .critical:
            "Immediate risk or safety event."
        }
    }

    static func < (
        lhs: NavigationPriority,
        rhs: NavigationPriority
    ) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

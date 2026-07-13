//
//  HapticCueFamily.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

enum HapticCueFamily: String, Codable, CaseIterable, Identifiable {
    case direction = "HAP-DIR"
    case obstacle = "HAP-OBS"
    case destination = "HAP-DST"
    case context = "HAP-CTX"
    case safety = "HAP-SEC"
    case system = "HAP-SYS"

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .direction:
            "Direction"
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
}

//
//  AudioCueFamily.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

enum AudioCueFamily: String, Codable, CaseIterable, Identifiable {
    case direction = "AUD-DIR"
    case obstacle = "AUD-OBS"
    case destination = "AUD-DST"
    case context = "AUD-CTX"
    case safety = "AUD-SEC"
    case system = "AUD-SYS"

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

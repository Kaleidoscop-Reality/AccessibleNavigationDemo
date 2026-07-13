//
//  ScenarioStatus.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

enum ScenarioStatus: String, Codable, CaseIterable, Identifiable {
    case idle
    case running
    case paused
    case completed
    case cancelled

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .idle:
            "Not Started"
        case .running:
            "Running"
        case .paused:
            "Paused"
        case .completed:
            "Completed"
        case .cancelled:
            "Cancelled"
        }
    }
}

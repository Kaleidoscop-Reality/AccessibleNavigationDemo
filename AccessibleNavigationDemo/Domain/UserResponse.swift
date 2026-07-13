//
//  UserResponse.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

enum UserResponse: String, Codable, CaseIterable, Identifiable {
    case pending
    case acknowledged
    case repeated
    case completed
    case ignored
    case cancelled
    case emergencyStop

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .pending:
            "Pending"
        case .acknowledged:
            "Acknowledged"
        case .repeated:
            "Repeated"
        case .completed:
            "Completed"
        case .ignored:
            "Ignored"
        case .cancelled:
            "Cancelled"
        case .emergencyStop:
            "Emergency Stop"
        }
    }
}

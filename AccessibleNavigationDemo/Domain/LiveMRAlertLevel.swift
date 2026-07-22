//
//  LiveMRAlertLevel.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 22/7/26.
//

import Foundation
import SwiftUI

enum LiveMRAlertLevel: Equatable {
    case scanning
    case ready
    case advisory
    case warning
    case critical
    case destination

    var color: Color {
        switch self {
        case .scanning:
            return .gray
        case .ready:
            return .blue
        case .advisory:
            return .yellow
        case .warning:
            return .orange
        case .critical:
            return .red
        case .destination:
            return .green
        }
    }

    var systemImage: String {
        switch self {
        case .scanning:
            return "viewfinder"
        case .ready:
            return "checkmark.circle"
        case .advisory:
            return "info.circle"
        case .warning:
            return "exclamationmark.triangle"
        case .critical:
            return "octagon.fill"
        case .destination:
            return "flag.checkered"
        }
    }
}

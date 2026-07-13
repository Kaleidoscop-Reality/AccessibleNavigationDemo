//
//  ScenarioState.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

struct ScenarioState: Codable, Hashable {
    var currentIndex: Int
    var status: ScenarioStatus

    static let initial = ScenarioState(
        currentIndex: 0,
        status: .idle
    )
}

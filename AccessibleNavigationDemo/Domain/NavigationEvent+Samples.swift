//
//  NavigationEvent+Samples.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

extension NavigationEvent {
    static let sampleEvents: [NavigationEvent] = [
        NavigationEvent(
            id: "EVT-001",
            entityId: "ROUTE-001",
            entityType: .accessibleRoute,
            title: "Route Started",
            instruction: "Route started. Continue straight.",
            direction: .straight,
            priority: .medium,
            audioCueFamily: .direction,
            hapticCueFamily: .direction,
            distanceMeters: nil,
            semanticDescription: "Beginning of an accessible route.",
            expectedResponse: "Begin moving forward.",
            userResponse: .pending
        ),

        NavigationEvent(
            id: "EVT-002",
            entityId: "LANDMARK-001",
            entityType: .landmark,
            title: "Landmark",
            instruction: "Reception desk on your right.",
            direction: .straight,
            priority: .low,
            audioCueFamily: .context,
            hapticCueFamily: .context,
            distanceMeters: 4,
            semanticDescription: "Orientation landmark located to the right.",
            expectedResponse: "Use the landmark for orientation.",
            userResponse: .pending
        ),

        NavigationEvent(
            id: "EVT-003",
            entityId: "DECISION-001",
            entityType: .decisionPoint,
            title: "Turn Left",
            instruction: "Turn left in three metres.",
            direction: .left,
            priority: .medium,
            audioCueFamily: .direction,
            hapticCueFamily: .direction,
            distanceMeters: 3,
            semanticDescription: "Route decision point requiring a left turn.",
            expectedResponse: "Turn left.",
            userResponse: .pending
        ),

        NavigationEvent(
            id: "EVT-004",
            entityId: "OBSTACLE-001",
            entityType: .obstacle,
            title: "Obstacle Ahead",
            instruction: "Obstacle ahead. Move slightly left.",
            direction: .straight,
            priority: .high,
            audioCueFamily: .obstacle,
            hapticCueFamily: .obstacle,
            distanceMeters: 2,
            semanticDescription: "Temporary obstacle blocking part of the route.",
            expectedResponse: "Reduce speed and move left.",
            userResponse: .pending
        ),

        NavigationEvent(
            id: "EVT-005",
            entityId: "RISK-001",
            entityType: .riskZone,
            title: "Critical Risk",
            instruction: "Stop. Unsafe area ahead.",
            direction: .straight,
            priority: .critical,
            audioCueFamily: .safety,
            hapticCueFamily: .safety,
            distanceMeters: 1,
            semanticDescription: "Immediate safety risk in the route.",
            expectedResponse: "Stop immediately.",
            userResponse: .pending
        ),

        NavigationEvent(
            id: "EVT-006",
            entityId: "SYSTEM-001",
            entityType: .systemReliabilityState,
            title: "Low Reliability",
            instruction: "Navigation reliability is low. Please stop.",
            direction: .straight,
            priority: .high,
            audioCueFamily: .system,
            hapticCueFamily: .system,
            distanceMeters: nil,
            semanticDescription: "The localisation system cannot guarantee safe guidance.",
            expectedResponse: "Stop and wait for recovery.",
            userResponse: .pending
        ),

        NavigationEvent(
            id: "EVT-007",
            entityId: "DESTINATION-001",
            entityType: .destination,
            title: "Destination Reached",
            instruction: "You have reached your destination.",
            direction: .straight,
            priority: .medium,
            audioCueFamily: .destination,
            hapticCueFamily: .destination,
            distanceMeters: 0,
            semanticDescription: "Final destination of the route.",
            expectedResponse: "Stop navigation.",
            userResponse: .pending
        )
    ]
}

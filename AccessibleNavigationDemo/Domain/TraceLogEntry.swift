//
//  TraceLogEntry.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

struct TraceLogEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let timestamp: Date
    let action: TraceAction

    let eventId: String?
    let entityId: String?
    let eventTitle: String?
    let priority: NavigationPriority?

    let message: String

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        action: TraceAction,
        eventId: String? = nil,
        entityId: String? = nil,
        eventTitle: String? = nil,
        priority: NavigationPriority? = nil,
        message: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.action = action
        self.eventId = eventId
        self.entityId = entityId
        self.eventTitle = eventTitle
        self.priority = priority
        self.message = message
    }
}

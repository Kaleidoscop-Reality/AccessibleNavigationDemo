//
//  EventLogService.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class EventLogService {

    private(set) var entries: [TraceLogEntry] = []

    var isEmpty: Bool {
        entries.isEmpty
    }

    var entryCount: Int {
        entries.count
    }

    func record(
        action: TraceAction,
        event: NavigationEvent? = nil,
        message: String
    ) {
        let entry = TraceLogEntry(
            action: action,
            eventId: event?.id,
            entityId: event?.entityId,
            eventTitle: event?.title,
            priority: event?.priority,
            message: message
        )

        entries.append(entry)
    }

    func clear() {
        entries.removeAll()
    }
}

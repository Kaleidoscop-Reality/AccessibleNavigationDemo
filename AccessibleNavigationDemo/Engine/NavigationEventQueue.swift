//
//  NavigationEventQueue.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 17/7/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class NavigationEventQueue {

    private(set) var events: [NavigationEvent] = []

    var isEmpty: Bool {
        events.isEmpty
    }

    var count: Int {
        events.count
    }

    var nextEvent: NavigationEvent? {
        events.first
    }

    func enqueue(
        _ event: NavigationEvent
    ) {
        events.append(event)

        events.sort {
            if $0.priority == $1.priority {
                return false
            }

            return $0.priority > $1.priority
        }
    }

    @discardableResult
    func dequeue() -> NavigationEvent? {
        guard !events.isEmpty else {
            return nil
        }

        return events.removeFirst()
    }

    func remove(
        eventId: String
    ) {
        events.removeAll {
            $0.id == eventId
        }
    }

    func removeAll() {
        events.removeAll()
    }

    func contains(
        eventId: String
    ) -> Bool {
        events.contains {
            $0.id == eventId
        }
    }
}

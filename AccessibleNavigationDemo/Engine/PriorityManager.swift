//
//  PriorityManager.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 17/7/26.
//

import Foundation

enum PriorityResolutionAction: String, Codable, CaseIterable {
    case present
    case interrupt
    case queue
    case discard

    var title: String {
        switch self {
        case .present:
            "Present"
        case .interrupt:
            "Interrupt"
        case .queue:
            "Queue"
        case .discard:
            "Discard"
        }
    }
}

struct PriorityResolution: Codable, Hashable {

    let action: PriorityResolutionAction

    let incomingEventId: String
    let incomingPriority: NavigationPriority

    let activeEventId: String?
    let activePriority: NavigationPriority?

    let reason: String

    var shouldPresentImmediately: Bool {
        action == .present || action == .interrupt
    }

    var shouldInterruptCurrentEvent: Bool {
        action == .interrupt
    }

    var shouldQueueEvent: Bool {
        action == .queue
    }

    var shouldDiscardEvent: Bool {
        action == .discard
    }
}

struct PriorityManager {

    func resolve(
        incomingEvent: NavigationEvent,
        activeEvent: NavigationEvent?
    ) -> PriorityResolution {

        guard let activeEvent else {
            return PriorityResolution(
                action: .present,
                incomingEventId: incomingEvent.id,
                incomingPriority: incomingEvent.priority,
                activeEventId: nil,
                activePriority: nil,
                reason: """
                No navigation event is currently active. \
                The incoming event can be presented immediately.
                """
            )
        }

        if shouldDiscardDuplicate(
            incomingEvent: incomingEvent,
            activeEvent: activeEvent
        ) {
            return PriorityResolution(
                action: .discard,
                incomingEventId: incomingEvent.id,
                incomingPriority: incomingEvent.priority,
                activeEventId: activeEvent.id,
                activePriority: activeEvent.priority,
                reason: """
                The incoming event duplicates the active informative \
                event and does not add new navigation information.
                """
            )
        }

        if incomingEvent.priority > activeEvent.priority {
            return PriorityResolution(
                action: .interrupt,
                incomingEventId: incomingEvent.id,
                incomingPriority: incomingEvent.priority,
                activeEventId: activeEvent.id,
                activePriority: activeEvent.priority,
                reason: """
                The incoming event has a higher priority than the \
                active event and must interrupt it.
                """
            )
        }

        if incomingEvent.priority == activeEvent.priority {
            return PriorityResolution(
                action: .queue,
                incomingEventId: incomingEvent.id,
                incomingPriority: incomingEvent.priority,
                activeEventId: activeEvent.id,
                activePriority: activeEvent.priority,
                reason: """
                The incoming event has the same priority as the \
                active event and must be queued.
                """
            )
        }

        return PriorityResolution(
            action: .queue,
            incomingEventId: incomingEvent.id,
            incomingPriority: incomingEvent.priority,
            activeEventId: activeEvent.id,
            activePriority: activeEvent.priority,
            reason: """
            The incoming event has a lower priority than the active \
            event and must not interrupt it.
            """
        )
    }

    private func shouldDiscardDuplicate(
        incomingEvent: NavigationEvent,
        activeEvent: NavigationEvent
    ) -> Bool {

        guard incomingEvent.priority <= .low else {
            return false
        }

        return incomingEvent.entityId == activeEvent.entityId &&
            incomingEvent.entityType == activeEvent.entityType &&
            incomingEvent.direction == activeEvent.direction
    }
}

//
//  TraceAction.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation

enum TraceAction: String, Codable, CaseIterable, Identifiable {
    case scenarioStarted
    case scenarioPaused
    case scenarioResumed
    case scenarioCompleted
    case scenarioCancelled
    case scenarioRestarted

    case eventPresented
    case eventAcknowledged
    case eventRepeated
    case eventCompleted
    case previousEventRequested
    case emergencyStop

    case audioCueDelivered
    case audioCueRepeated
    case audioCueStopped
    
    case hapticCueDelivered
    case hapticCueRepeated
    case hapticCueStopped
    case hapticFallbackApplied
    
    case preferenceProfileChanged
    case deviceCapabilitiesUpdated
    case eventFiltered
    case fallbackApplied
    case unsafeDeliveryDetected
    
    case incomingEventReceived
    case eventInterrupted
    case eventQueued
    case queuedEventPresented
    case eventDiscarded

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
            case .scenarioStarted:
                "Scenario Started"
            case .scenarioPaused:
                "Scenario Paused"
            case .scenarioResumed:
                "Scenario Resumed"
            case .scenarioCompleted:
                "Scenario Completed"
            case .scenarioCancelled:
                "Scenario Cancelled"
            case .scenarioRestarted:
                "Scenario Restarted"

            case .eventPresented:
                "Event Presented"
            case .eventAcknowledged:
                "Event Acknowledged"
            case .eventRepeated:
                "Event Repeated"
            case .eventCompleted:
                "Event Completed"
            case .previousEventRequested:
                "Previous Event Requested"
            case .emergencyStop:
                "Emergency Stop"

            case .audioCueDelivered:
                "Audio Cue Delivered"
            case .audioCueRepeated:
                "Audio Cue Repeated"
            case .audioCueStopped:
                "Audio Cue Stopped"
                
            case .hapticCueDelivered:
                "Haptic Cue Delivered"
            case .hapticCueRepeated:
                "Haptic Cue Repeated"
            case .hapticCueStopped:
                "Haptic Cue Stopped"
            case .hapticFallbackApplied:
                "Haptic Fallback Applied"
                
            case .preferenceProfileChanged:
                "Preference Profile Changed"
            case .deviceCapabilitiesUpdated:
                "Device Capabilities Updated"
            case .eventFiltered:
                "Event Filtered"
            case .fallbackApplied:
                "Fallback Applied"
            case .unsafeDeliveryDetected:
                "Unsafe Delivery Detected"
            
            case .incomingEventReceived:
                "Incoming Event Received"
            case .eventInterrupted:
                "Event Interrupted"
            case .eventQueued:
                "Event Queued"
            case .queuedEventPresented:
                "Queued Event Presented"
            case .eventDiscarded:
                "Event Discarded"
        }
    }
}

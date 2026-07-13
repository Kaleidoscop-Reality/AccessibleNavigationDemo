//
//  EventDetailView.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import SwiftUI

struct EventDetailView: View {
    let event: NavigationEvent

    var body: some View {
        List {
            Section("Event") {
                LabeledContent("ID", value: event.id)
                LabeledContent("Title", value: event.title)
                LabeledContent("Instruction", value: event.instruction)
            }

            Section("Metadata") {
                LabeledContent(
                    "Entity",
                    value: event.entityType.title
                )

                LabeledContent(
                    "Entity ID",
                    value: event.entityId
                )

                LabeledContent(
                    "Semantic meaning",
                    value: event.semanticDescription
                )

                if let distance = event.distanceMeters {
                    LabeledContent(
                        "Distance",
                        value: "\(distance.formatted()) m"
                    )
                }
            }

            Section("Priority") {
                LabeledContent(
                    "Level",
                    value: "\(event.priority.code) · \(event.priority.title)"
                )

                Text(event.priority.description)
                    .foregroundStyle(.secondary)
            }

            Section("Accessible Output") {
                LabeledContent(
                    "Audio",
                    value: event.audioCueFamily.rawValue
                )

                LabeledContent(
                    "Haptic",
                    value: event.hapticCueFamily.rawValue
                )
            }

            Section("Response") {
                LabeledContent(
                    "Expected",
                    value: event.expectedResponse
                )

                LabeledContent(
                    "Current",
                    value: event.userResponse.title
                )
            }
        }
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        EventDetailView(
            event: NavigationEvent.sampleEvents[0]
        )
    }
}

//
//  EventLogView.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import SwiftUI

struct EventLogView: View {

    let logger: EventLogService

    var body: some View {
        Group {
            if logger.isEmpty {
                ContentUnavailableView(
                    "No Traceability Data",
                    systemImage: "list.bullet.clipboard",
                    description: Text(
                        "Start the demonstration to generate log entries."
                    )
                )
            } else {
                List {
                    Section {
                        LabeledContent(
                            "Recorded entries",
                            value: logger.entryCount.formatted()
                        )
                    }

                    Section("Traceability Log") {
                        ForEach(
                            logger.entries.reversed()
                        ) { entry in
                            logEntryView(entry)
                        }
                    }
                }
            }
        }
        .navigationTitle("Event Log")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func logEntryView(
        _ entry: TraceLogEntry
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.action.title)
                    .font(.headline)

                Spacer()

                Text(
                    entry.timestamp,
                    format: .dateTime
                        .hour()
                        .minute()
                        .second()
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Text(entry.message)
                .font(.subheadline)

            if let eventId = entry.eventId {
                HStack(spacing: 8) {
                    Text(eventId)

                    if let priority = entry.priority {
                        Text(priority.code)
                    }

                    if let entityId = entry.entityId {
                        Text(entityId)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

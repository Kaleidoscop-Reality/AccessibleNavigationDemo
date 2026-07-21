//
//  LiveStandardsInspectorView.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 21/7/26.
//

import SwiftUI

@MainActor
struct LiveStandardsInspectorView: View {

    @Bindable var engine: ScenarioEngine

    var body: some View {
        List {
            eventStateSection
            prioritySection
            queueSection
            deliverySection
            serviceSection
            traceabilitySection
        }
        .navigationTitle("Standards Inspector")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var eventStateSection: some View {
        Section("Event State") {
            eventRow(
                title: "Displayed event",
                event: engine.displayedEvent
            )

            eventRow(
                title: "Dynamic event",
                event: engine.activeDynamicEvent
            )

            eventRow(
                title: "Walkthrough event",
                event: engine.currentEvent
            )

            eventRow(
                title: "Last incoming event",
                event: engine.lastIncomingEvent
            )

            LabeledContent(
                "Scenario status",
                value: engine.state.status.title
            )

            LabeledContent(
                "Active profile",
                value: engine.activeProfile.name
            )
        }
    }

    @ViewBuilder
    private var prioritySection: some View {
        Section("Priority Resolution") {
            if let resolution = engine.lastPriorityResolution {
                LabeledContent(
                    "Action",
                    value: resolution.action.title
                )

                LabeledContent(
                    "Incoming priority",
                    value: resolution.incomingPriority.code
                )

                LabeledContent(
                    "Active priority",
                    value: resolution.activePriority?.code ?? "None"
                )

                Text(resolution.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("No priority decision recorded.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var queueSection: some View {
        Section("Event Queue") {
            LabeledContent(
                "Queue size",
                value: engine.queuedEventCount.formatted()
            )

            if engine.eventQueue.events.isEmpty {
                Text("No queued events.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(engine.eventQueue.events) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(event.title)

                            Spacer()

                            Text(event.priority.code)
                                .foregroundStyle(.secondary)
                        }

                        Text(event.id)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var deliverySection: some View {
        Section("Delivery Resolution") {
            if let resolution = engine.lastFallbackResolution {
                LabeledContent(
                    "Audio",
                    value: yesNo(resolution.deliverAudio)
                )

                LabeledContent(
                    "Haptics",
                    value: yesNo(resolution.deliverHaptics)
                )

                LabeledContent(
                    "Visual",
                    value: yesNo(resolution.deliverVisual)
                )

                LabeledContent(
                    "Spatial audio",
                    value: yesNo(resolution.useSpatialAudio)
                )

                LabeledContent(
                    "Fallback",
                    value: fallbackTitle(resolution)
                )

                LabeledContent(
                    "Safe delivery",
                    value: yesNo(resolution.isSafe)
                )

                Text(resolution.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("No delivery resolution recorded.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var serviceSection: some View {
        Section("Output Services") {
            LabeledContent(
                "Speech status",
                value: speechStatusTitle
            )

            LabeledContent(
                "Last spoken text",
                value: engine.speechService.lastSpokenText ?? "None"
            )

            LabeledContent(
                "Haptic support",
                value: engine.hapticService.supportsHaptics
                    ? "Available"
                    : "Fallback"
            )

            LabeledContent(
                "Haptic engine",
                value: engine.hapticService.isEngineRunning
                    ? "Running"
                    : "Stopped"
            )

            LabeledContent(
                "Last haptic pattern",
                value: engine.hapticService.lastPlayedPattern?.title
                    ?? "None"
            )
        }
    }

    @ViewBuilder
    private var traceabilitySection: some View {
        Section("Traceability") {
            LabeledContent(
                "Recorded entries",
                value: engine.logger.entryCount.formatted()
            )

            if let lastEntry = engine.logger.entries.last {
                LabeledContent(
                    "Last action",
                    value: lastEntry.action.title
                )

                Text(lastEntry.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("No traceability entries recorded.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func eventRow(
        title: String,
        event: NavigationEvent?
    ) -> some View {
        if let event {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)

                    Spacer()

                    Text(event.priority.code)
                        .foregroundStyle(.secondary)
                }

                Text(event.title)
                    .font(.subheadline)

                Text(event.id)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else {
            LabeledContent(
                title,
                value: "None"
            )
        }
    }

    private var speechStatusTitle: String {
        if engine.speechService.isPaused {
            return "Paused"
        }

        if engine.speechService.isSpeaking {
            return "Speaking"
        }

        return "Idle"
    }

    private func yesNo(
        _ value: Bool
    ) -> String {
        value ? "Yes" : "No"
    }

    private func fallbackTitle(
        _ resolution: FallbackResolution
    ) -> String {
        guard resolution.fallbackApplied else {
            return "Not required"
        }

        return resolution.fallbackModality?.title
            ?? "Applied"
    }
}

#Preview {
    NavigationStack {
        LiveStandardsInspectorView(
            engine: ScenarioEngine()
        )
    }
}

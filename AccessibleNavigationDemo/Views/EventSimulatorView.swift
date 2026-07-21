//
//  EventSimulatorView.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 20/7/26.
//

import Foundation
import SwiftUI

@MainActor
struct EventSimulatorView: View {

    @Bindable var engine: ScenarioEngine

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                simulatorStatusSection
                activeEventSection
                eventControlsSection
                dynamicEventActionsSection
                priorityDecisionSection
                deliveryResolutionSection
            }
            .padding()
        }
        .navigationTitle("Event Simulator")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink {
                    LiveStandardsInspectorView(engine: engine)
                } label: {
                    Label(
                        "Standards Inspector",
                        systemImage: "waveform.path.ecg.rectangle"
                    )
                }

                NavigationLink {
                    ProfileView(engine: engine)
                } label: {
                    Label(
                        "User Profile",
                        systemImage: "person.crop.circle"
                    )
                }

                NavigationLink {
                    EventLogView(logger: engine.logger)
                } label: {
                    Label(
                        "Event Log",
                        systemImage: "list.bullet.clipboard"
                    )
                }
            }
        }
    }

    private var simulatorStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Simulator Status")
                .font(.headline)

            LabeledContent(
                "Active profile",
                value: engine.activeProfile.name
            )

            LabeledContent(
                "Dynamic event",
                value: engine.hasActiveDynamicEvent
                    ? "Active"
                    : "None"
            )

            LabeledContent(
                "Queued events",
                value: engine.queuedEventCount.formatted()
            )

            LabeledContent(
                "Scenario status",
                value: engine.state.status.title
            )
        }
        .simulatorCard()
    }

    @ViewBuilder
    private var activeEventSection: some View {
        if let event = engine.displayedEvent {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Active Event")
                        .font(.headline)

                    Spacer()

                    Text(event.priority.code)
                        .font(.headline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                }

                Text(event.title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(event.instruction)

                LabeledContent(
                    "Entity",
                    value: event.entityType.title
                )

                LabeledContent(
                    "Audio family",
                    value: event.audioCueFamily.rawValue
                )

                LabeledContent(
                    "Haptic family",
                    value: event.hapticCueFamily.rawValue
                )

                if engine.hasActiveDynamicEvent {
                    Label(
                        "Dynamic event",
                        systemImage: "bolt.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } else {
                    Label(
                        "Walkthrough event",
                        systemImage: "figure.walk"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .simulatorCard()
        } else {
            ContentUnavailableView(
                "No Active Event",
                systemImage: "waveform.path.ecg",
                description: Text(
                    "Trigger an event to start the simulation."
                )
            )
        }
    }

    private var eventControlsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trigger Events")
                .font(.headline)

            simulatorButton(
                title: "Context Information",
                subtitle: "P0 · Informative",
                systemImage: "info.circle",
                event: makeContextEvent()
            )

            simulatorButton(
                title: "Landmark Detected",
                subtitle: "P1 · Low",
                systemImage: "mappin.and.ellipse",
                event: makeLandmarkEvent()
            )

            simulatorButton(
                title: "Turn Left",
                subtitle: "P2 · Medium",
                systemImage: "arrow.turn.up.left",
                event: makeTurnLeftEvent()
            )

            simulatorButton(
                title: "Obstacle Ahead",
                subtitle: "P3 · High",
                systemImage: "exclamationmark.triangle",
                event: makeObstacleEvent()
            )

            simulatorButton(
                title: "Critical Risk",
                subtitle: "P4 · Critical",
                systemImage: "exclamationmark.octagon.fill",
                event: makeCriticalRiskEvent()
            )

            simulatorButton(
                title: "Low Reliability",
                subtitle: "P3 · High",
                systemImage: "antenna.radiowaves.left.and.right.slash",
                event: makeReliabilityEvent()
            )

            simulatorButton(
                title: "Destination Reached",
                subtitle: "P2 · Medium",
                systemImage: "flag.checkered",
                event: makeDestinationEvent()
            )
        }
        .simulatorCard()
    }

    @ViewBuilder
    private var dynamicEventActionsSection: some View {
        if engine.hasActiveDynamicEvent {
            VStack(alignment: .leading, spacing: 12) {
                Text("Dynamic Event Controls")
                    .font(.headline)

                HStack {
                    Button {
                        engine.repeatActiveDynamicEvent()
                    } label: {
                        Label(
                            "Repeat",
                            systemImage: "repeat"
                        )
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button {
                        engine.completeActiveDynamicEvent()
                    } label: {
                        Label(
                            "Complete",
                            systemImage: "checkmark.circle"
                        )
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .simulatorCard()
        }
    }

    @ViewBuilder
    private var priorityDecisionSection: some View {
        if let resolution = engine.lastPriorityResolution {
            VStack(alignment: .leading, spacing: 12) {
                Text("Priority Decision")
                    .font(.headline)

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
                    value: resolution.activePriority?.code
                        ?? "None"
                )

                Text(resolution.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .simulatorCard()
        }
    }

    @ViewBuilder
    private var deliveryResolutionSection: some View {
        if let resolution = engine.lastFallbackResolution {
            VStack(alignment: .leading, spacing: 12) {
                Text("Delivery Resolution")
                    .font(.headline)

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
            }
            .simulatorCard()
        }
    }

    private func simulatorButton(
        title: String,
        subtitle: String,
        systemImage: String,
        event: NavigationEvent
    ) -> some View {
        Button {
            engine.receive(event)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "play.fill")
                    .font(.caption)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 6)
    }

    private func makeContextEvent() -> NavigationEvent {
        NavigationEvent(
            id: dynamicId(prefix: "SIM-CTX"),
            entityId: "SIM-CONTEXT-001",
            entityType: .pointOfInterest,
            title: "Context Information",
            instruction: "There is an information desk on your right.",
            direction: .right,
            priority: .informative,
            audioCueFamily: .context,
            hapticCueFamily: .context,
            distanceMeters: 4,
            semanticDescription: """
            Optional contextual information near the current route.
            """,
            expectedResponse: """
            Continue or request additional information.
            """,
            userResponse: .pending
        )
    }

    private func makeLandmarkEvent() -> NavigationEvent {
        NavigationEvent(
            id: dynamicId(prefix: "SIM-LMK"),
            entityId: "SIM-LANDMARK-001",
            entityType: .landmark,
            title: "Landmark Detected",
            instruction: """
            Reception desk detected ahead on your left.
            """,
            direction: .slightLeft,
            priority: .low,
            audioCueFamily: .context,
            hapticCueFamily: .context,
            distanceMeters: 6,
            semanticDescription: """
            A landmark that supports orientation along the route.
            """,
            expectedResponse: """
            Use the landmark to confirm the current position.
            """,
            userResponse: .pending
        )
    }

    private func makeTurnLeftEvent() -> NavigationEvent {
        NavigationEvent(
            id: dynamicId(prefix: "SIM-DIR"),
            entityId: "SIM-DECISION-001",
            entityType: .decisionPoint,
            title: "Turn Left",
            instruction: "Turn left in three metres.",
            direction: .left,
            priority: .medium,
            audioCueFamily: .direction,
            hapticCueFamily: .direction,
            distanceMeters: 3,
            semanticDescription: """
            A route decision requires a left turn.
            """,
            expectedResponse: """
            Prepare to turn left and follow the accessible route.
            """,
            userResponse: .pending
        )
    }

    private func makeObstacleEvent() -> NavigationEvent {
        NavigationEvent(
            id: dynamicId(prefix: "SIM-OBS"),
            entityId: "SIM-OBSTACLE-001",
            entityType: .obstacle,
            title: "Obstacle Ahead",
            instruction: """
            Obstacle ahead. Reduce speed and move slightly left.
            """,
            direction: .slightLeft,
            priority: .high,
            audioCueFamily: .obstacle,
            hapticCueFamily: .obstacle,
            distanceMeters: 2,
            semanticDescription: """
            A temporary obstacle is blocking part of the route.
            """,
            expectedResponse: """
            Reduce speed and move left when it is safe.
            """,
            userResponse: .pending
        )
    }

    private func makeCriticalRiskEvent() -> NavigationEvent {
        NavigationEvent(
            id: dynamicId(prefix: "SIM-SEC"),
            entityId: "SIM-RISK-001",
            entityType: .riskZone,
            title: "Critical Risk",
            instruction: """
            Stop immediately. Unsafe drop detected ahead.
            """,
            direction: .straight,
            priority: .critical,
            audioCueFamily: .safety,
            hapticCueFamily: .safety,
            distanceMeters: 1,
            semanticDescription: """
            An immediate safety risk requires the user to stop.
            """,
            expectedResponse: """
            Stop immediately and wait for a safe instruction.
            """,
            userResponse: .pending
        )
    }

    private func makeReliabilityEvent() -> NavigationEvent {
        NavigationEvent(
            id: dynamicId(prefix: "SIM-SYS"),
            entityId: "SIM-RELIABILITY-001",
            entityType: .systemReliabilityState,
            title: "Low Reliability",
            instruction: """
            Navigation confidence is low. Proceed with caution.
            """,
            direction: nil,
            priority: .high,
            audioCueFamily: .system,
            hapticCueFamily: .system,
            distanceMeters: nil,
            semanticDescription: """
            The navigation system cannot determine the route \
            with sufficient confidence.
            """,
            expectedResponse: """
            Slow down and wait for updated navigation guidance.
            """,
            userResponse: .pending
        )
    }

    private func makeDestinationEvent() -> NavigationEvent {
        NavigationEvent(
            id: dynamicId(prefix: "SIM-DST"),
            entityId: "SIM-DESTINATION-001",
            entityType: .destination,
            title: "Destination Reached",
            instruction: "You have reached your destination.",
            direction: nil,
            priority: .medium,
            audioCueFamily: .destination,
            hapticCueFamily: .destination,
            distanceMeters: 0,
            semanticDescription: """
            The destination associated with the current route \
            has been reached.
            """,
            expectedResponse: """
            Stop navigation and confirm arrival.
            """,
            userResponse: .pending
        )
    }

    private func dynamicId(
        prefix: String
    ) -> String {
        "\(prefix)-\(UUID().uuidString)"
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

private extension View {

    func simulatorCard() -> some View {
        self
            .padding()
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(.regularMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18
                )
            )
    }
}

#Preview {
    NavigationStack {
        EventSimulatorView(
            engine: ScenarioEngine()
        )
    }
}

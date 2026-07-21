//
//  ScenarioDemoView.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import SwiftUI

@MainActor
struct ScenarioDemoView: View {

    @Bindable var engine: ScenarioEngine

    var body: some View {
        VStack(spacing: 20) {
            statusHeader

            switch engine.state.status {
            case .idle:
                startView

            case .running, .paused:
                activeScenarioView

            case .completed:
                completedView

            case .cancelled:
                cancelledView
            }
        }
        .padding()
        .navigationTitle("Demonstration")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
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

    private var statusHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text(engine.state.status.title)
                    .font(.headline)

                Spacer()

                if engine.hasActiveDynamicEvent {
                    Label(
                        "Dynamic event",
                        systemImage: "bolt.fill"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                } else {
                    Text(
                        "\(engine.currentPosition) / \(engine.totalEvents)"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }

            ProgressView(value: engine.progress)
        }
    }

    private var startView: some View {
        ContentUnavailableView {
            Label(
                "Accessible Navigation Demo",
                systemImage: "figure.walk.motion"
            )
        } description: {
            Text(
                "Run the simulated navigation scenario one event at a time."
            )
        } actions: {
            Button("Start Demonstration") {
                engine.start()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    private var activeScenarioView: some View {
        if let event = engine.displayedEvent {
            ScrollView {
                VStack(spacing: 20) {
                    eventCard(event)

                    if engine.hasActiveDynamicEvent {
                        dynamicResponseSection(event)
                        dynamicControlSection
                    } else {
                        walkthroughResponseSection(event)
                        walkthroughControlSection
                    }

                    emergencyControlSection
                }
            }
        } else {
            ContentUnavailableView(
                "No Event",
                systemImage: "exclamationmark.triangle",
                description: Text(
                    "The current scenario event is unavailable."
                )
            )
        }
    }

    private func eventCard(
        _ event: NavigationEvent
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(event.priority.code)
                    .font(.headline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.thinMaterial)
                    .clipShape(Capsule())

                Spacer()

                Text(event.entityType.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if engine.hasActiveDynamicEvent {
                Label(
                    "Dynamic navigation event",
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

            Text(event.title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(event.instruction)
                .font(.title3)

            if let distance = event.distanceMeters {
                Label(
                    "\(distance.formatted()) metres",
                    systemImage: "ruler"
                )
            }

            Divider()

            LabeledContent(
                "Audio",
                value: event.audioCueFamily.rawValue
            )

            LabeledContent(
                "Haptic",
                value: event.hapticCueFamily.rawValue
            )

            LabeledContent(
                "Expected response",
                value: event.expectedResponse
            )

            LabeledContent(
                "Speech status",
                value: speechStatusTitle
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
                "Last pattern",
                value: engine.hapticService.lastPlayedPattern?.title
                    ?? "None"
            )

            if engine.hasActiveDynamicEvent {
                LabeledContent(
                    "Queued events",
                    value: engine.queuedEventCount.formatted()
                )
            }
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(.regularMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }

    private func walkthroughResponseSection(
        _ event: NavigationEvent
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("User Response")
                .font(.headline)

            Text(event.userResponse.title)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            HStack {
                Button("Acknowledge") {
                    engine.acknowledgeCurrentEvent()
                }
                .buttonStyle(.borderedProminent)

                Button("Repeat") {
                    engine.repeatCurrentEvent()
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    private func dynamicResponseSection(
        _ event: NavigationEvent
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dynamic Event")
                .font(.headline)

            Text(
                "This event temporarily has priority over the walkthrough event."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            LabeledContent(
                "Priority",
                value: "\(event.priority.code) · \(event.priority.title)"
            )

            LabeledContent(
                "Queued events",
                value: engine.queuedEventCount.formatted()
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    private var walkthroughControlSection: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    engine.moveToPreviousEvent()
                } label: {
                    Label(
                        "Previous",
                        systemImage: "chevron.left"
                    )
                }
                .disabled(
                    !engine.canMovePrevious ||
                    engine.state.status == .paused
                )

                Spacer()

                Button {
                    engine.completeCurrentEvent()
                    engine.moveToNextEvent()
                } label: {
                    Label(
                        engine.canMoveNext ? "Next" : "Finish",
                        systemImage: "chevron.right"
                    )
                }
                .buttonStyle(.borderedProminent)
                .disabled(engine.state.status == .paused)
            }

            HStack {
                if engine.state.status == .paused {
                    Button("Resume") {
                        engine.resume()
                    }
                } else {
                    Button("Pause") {
                        engine.pause()
                    }
                }

                Spacer()
            }
        }
    }

    private var dynamicControlSection: some View {
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
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    private var emergencyControlSection: some View {
        HStack {
            Spacer()

            Button(
                "Emergency Stop",
                role: .destructive
            ) {
                engine.emergencyStop()
            }
        }
    }

    private var completedView: some View {
        ContentUnavailableView {
            Label(
                "Demonstration Completed",
                systemImage: "checkmark.circle"
            )
        } description: {
            Text(
                "All navigation events have been processed."
            )
        } actions: {
            Button("Restart") {
                engine.restart()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var cancelledView: some View {
        ContentUnavailableView {
            Label(
                "Demonstration Stopped",
                systemImage: "stop.circle"
            )
        } description: {
            Text(
                "The scenario was cancelled or stopped for safety."
            )
        } actions: {
            Button("Restart") {
                engine.restart()
            }
            .buttonStyle(.borderedProminent)
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
}

#Preview {
    NavigationStack {
        ScenarioDemoView(
            engine: ScenarioEngine()
        )
    }
}

//
//  HomeView.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 20/7/26.
//

import SwiftUI

@MainActor
struct HomeView: View {

@State private var walkthroughEngine: ScenarioEngine
@State private var simulatorEngine: ScenarioEngine

init() {
    _walkthroughEngine = State(
        initialValue: ScenarioEngine()
    )

    _simulatorEngine = State(
        initialValue: ScenarioEngine()
    )
}

var body: some View {
    NavigationStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                experienceSection
                systemStatusSection
            }
            .padding()
        }
        .navigationTitle("Accessible Navigation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private var headerSection: some View {
    VStack(alignment: .leading, spacing: 12) {
        Image(systemName: "figure.walk.motion")
            .font(.system(size: 42))
            .foregroundStyle(.tint)
            .accessibilityHidden(true)

        Text("Accessible Navigation Demo")
            .font(.largeTitle)
            .fontWeight(.bold)

        Text(
            """
            Learn how semantic navigation events become accessible, \
            prioritised and traceable user instructions.
            """
        )
        .foregroundStyle(.secondary)
    }
    .frame(
        maxWidth: .infinity,
        alignment: .leading
    )
}

private var experienceSection: some View {
    VStack(alignment: .leading, spacing: 14) {
        Text("Experiences")
            .font(.headline)

        NavigationLink {
            ScenarioDemoView(
                engine: walkthroughEngine
            )
        } label: {
            experienceCard(
                title: "Learn the Standards",
                description: """
                Follow a guided sequence of navigation events and \
                understand their semantics, priorities and accessible \
                outputs.
                """,
                systemImage: "list.number",
                status: "Guided"
            )
        }
        .buttonStyle(.plain)

        NavigationLink {
            EventSimulatorView(
                engine: simulatorEngine
            )
        } label: {
            experienceCard(
                title: "Test the Standards",
                description: """
                Trigger events manually and test interruptions, \
                queueing, preferences, fallback and safety behaviour.
                """,
                systemImage: "waveform.path.ecg",
                status: "Interactive"
            )
        }
        .buttonStyle(.plain)

        NavigationLink {
            LiveMRDemoView()
        } label: {
            experienceCard(
                title: "Live MR Demo",
                description: """
                Place virtual navigation objects in the real environment \
                and test proximity-based accessible feedback.
                """,
                systemImage: "camera.viewfinder",
                status: "Planned"
            )
        }
        .buttonStyle(.plain)
    }
}

private var systemStatusSection: some View {
    VStack(alignment: .leading, spacing: 12) {
        Text("Experience Status")
            .font(.headline)

        LabeledContent(
            "Walkthrough",
            value: walkthroughEngine.state.status.title
        )

        LabeledContent(
            "Simulator active event",
            value: simulatorEngine.hasActiveDynamicEvent
                ? "Active"
                : "None"
        )

        LabeledContent(
            "Simulator queue",
            value: simulatorEngine.queuedEventCount.formatted()
        )

        LabeledContent(
            "Haptic support",
            value: simulatorEngine.deviceCapabilities.supportsHaptics
                ? "Available"
                : "Unavailable"
        )
    }
    .homeCard()
}

private func experienceCard(
    title: String,
    description: String,
    systemImage: String,
    status: String
) -> some View {
    HStack(alignment: .top, spacing: 16) {
        Image(systemName: systemImage)
            .font(.title2)
            .frame(width: 34)
            .foregroundStyle(.tint)
            .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Text(status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }

        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundStyle(.tertiary)
            .accessibilityHidden(true)
    }
    .homeCard()
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
        "\(title). \(status). \(description)"
    )
}


}

@MainActor
private struct LiveMRDemoPlaceholderView: View {

var body: some View {
    ContentUnavailableView {
        Label(
            "Live MR Demo",
            systemImage: "camera.viewfinder"
        )
    } description: {
        Text(
            """
            The live mixed reality experience will be implemented \
            after the interactive simulator is validated.
            """
        )
    } actions: {
        Text("RealityKit and ARKit integration planned")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    .navigationTitle("Live MR Demo")
    .navigationBarTitleDisplayMode(.inline)
}


}

private extension View {

func homeCard() -> some View {
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
HomeView()
}

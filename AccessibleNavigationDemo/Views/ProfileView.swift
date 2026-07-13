//
//  ProfileView.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import Foundation
import SwiftUI

@MainActor
struct ProfileView: View {

    @Bindable var engine: ScenarioEngine

    @State private var draftProfile: UserPreferenceProfile
    @State private var showingAppliedConfirmation = false

    init(engine: ScenarioEngine) {
        self.engine = engine

        _draftProfile = State(
            initialValue: engine.activeProfile
        )
    }

    var body: some View {
        Form {
            activeProfileSection
            predefinedProfilesSection
            outputModalitiesSection
            speechSection
            hapticsSection
            filteringSection
            contextSection
            applySection
        }
        .navigationTitle("User Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Profile Applied",
            isPresented: $showingAppliedConfirmation
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                "\(draftProfile.name) is now the active profile."
            )
        }
    }

    private var activeProfileSection: some View {
        Section("Active Profile") {
            LabeledContent(
                "Current",
                value: engine.activeProfile.name
            )

            LabeledContent(
                "Minimum priority",
                value: engine.activeProfile.minimumPriority.code
            )

            LabeledContent(
                "Audio",
                value: engine.activeProfile.audioEnabled
                    ? "Enabled"
                    : "Disabled"
            )

            LabeledContent(
                "Haptics",
                value: engine.activeProfile.hapticsEnabled
                    ? "Enabled"
                    : "Disabled"
            )
        }
    }

    private var predefinedProfilesSection: some View {
        Section {
            ForEach(
                UserPreferenceProfile.predefinedProfiles
            ) { profile in
                Button {
                    draftProfile = profile
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(profile.name)
                                .foregroundStyle(.primary)

                            Text(profile.detailLevel.title)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if draftProfile.id == profile.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
        } header: {
            Text("Predefined Profiles")
        } footer: {
            Text(
                "Select a profile and review its settings before applying it."
            )
        }
    }

    private var outputModalitiesSection: some View {
        Section("Output Modalities") {
            Toggle(
                "Audio",
                isOn: $draftProfile.audioEnabled
            )

            Toggle(
                "Haptics",
                isOn: $draftProfile.hapticsEnabled
            )

            Toggle(
                "Spatial Audio",
                isOn: $draftProfile.spatialAudioEnabled
            )
            .disabled(!draftProfile.audioEnabled)
        }
    }

    private var speechSection: some View {
        Section("Speech") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Volume")

                    Spacer()

                    Text(
                        draftProfile.speechVolume,
                        format: .percent.precision(
                            .fractionLength(0)
                        )
                    )
                    .foregroundStyle(.secondary)
                }

                Slider(
                    value: $draftProfile.speechVolume,
                    in: 0...1
                )
            }
            .disabled(!draftProfile.audioEnabled)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Speech rate")

                    Spacer()

                    Text(
                        draftProfile.speechRate,
                        format: .number.precision(
                            .fractionLength(2)
                        )
                    )
                    .foregroundStyle(.secondary)
                }

                Slider(
                    value: $draftProfile.speechRate,
                    in: 0.1...0.6
                )
            }
            .disabled(!draftProfile.audioEnabled)
        }
    }

    private var hapticsSection: some View {
        Section("Haptics") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Intensity")

                    Spacer()

                    Text(
                        draftProfile.hapticIntensity,
                        format: .percent.precision(
                            .fractionLength(0)
                        )
                    )
                    .foregroundStyle(.secondary)
                }

                Slider(
                    value: $draftProfile.hapticIntensity,
                    in: 0...1
                )
            }
            .disabled(!draftProfile.hapticsEnabled)

            LabeledContent(
                "Device support",
                value: engine.deviceCapabilities.supportsHaptics
                    ? "Available"
                    : "Unavailable"
            )
        }
    }

    private var filteringSection: some View {
        Section {
            Picker(
                "Minimum priority",
                selection: $draftProfile.minimumPriority
            ) {
                ForEach(NavigationPriority.allCases) { priority in
                    Text(
                        "\(priority.code) — \(priority.title)"
                    )
                    .tag(priority)
                }
            }

            Picker(
                "Detail level",
                selection: $draftProfile.detailLevel
            ) {
                ForEach(NavigationDetailLevel.allCases) { level in
                    Text(level.title)
                        .tag(level)
                }
            }
        } header: {
            Text("Event Filtering")
        } footer: {
            Text(
                "Critical P4 events are never filtered by user preferences."
            )
        }
    }

    private var contextSection: some View {
        Section("Additional Information") {
            Toggle(
                "Contextual events",
                isOn: $draftProfile.contextualEventsEnabled
            )

            Toggle(
                "Points of interest",
                isOn: $draftProfile.pointOfInterestEventsEnabled
            )

            Toggle(
                "Early warnings",
                isOn: $draftProfile.earlyWarningsEnabled
            )

            Toggle(
                "Allow repetition",
                isOn: $draftProfile.repetitionEnabled
            )
        }
    }

    private var applySection: some View {
        Section {
            Button {
                applyProfile()
            } label: {
                Text("Apply Profile")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func applyProfile() {
        engine.updateProfile(draftProfile)
        showingAppliedConfirmation = true
    }
}

//
//  ContentView.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 13/7/26.
//

import SwiftUI

struct ContentView: View {

    private let events = NavigationEvent.sampleEvents

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        ScenarioDemoView()
                    } label: {
                        Label(
                            "Start Demonstration",
                            systemImage: "play.circle.fill"
                        )
                    }
                }

                Section("Available Events") {
                    ForEach(events) { event in
                        NavigationLink {
                            EventDetailView(event: event)
                        } label: {
                            VStack(
                                alignment: .leading,
                                spacing: 6
                            ) {
                                Text(event.title)
                                    .font(.headline)

                                Text(event.instruction)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                HStack {
                                    Text(event.priority.code)
                                    Text(event.audioCueFamily.rawValue)
                                    Text(event.hapticCueFamily.rawValue)
                                }
                                .font(.caption)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Accessible Navigation")
        }
    }
}

//struct ContentView: View {
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 24) {
//                Spacer()
//
//                Image(systemName: "figure.walk.motion")
//                    .font(.system(size: 72))
//                    .accessibilityHidden(true)
//
//                VStack(spacing: 8) {
//                    Text("Accessible Navigation")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .multilineTextAlignment(.center)
//
//                    Text("Mixed Reality Standards Demonstrator")
//                        .font(.title3)
//                        .foregroundStyle(.secondary)
//                        .multilineTextAlignment(.center)
//                }
//
//                Text(
//                    "Prototype for demonstrating accessible navigation metadata, audio cues, haptic cues, user preferences and traceability."
//                )
//                .font(.body)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//
//                Spacer()
//
//                Button {
//                    // Se implementará en el siguiente paso
//                } label: {
//                    Text("Start Demonstration")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                }
//                .buttonStyle(.borderedProminent)
//                .accessibilityHint("Starts the accessible navigation demonstration")
//
//                Button {
//                    // Se implementará más adelante
//                } label: {
//                    Text("User Preferences")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                }
//                .buttonStyle(.bordered)
//
//                Button {
//                    // Se implementará más adelante
//                } label: {
//                    Text("Standards Inspector")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                }
//                .buttonStyle(.bordered)
//            }
//            .padding()
//            .navigationTitle("Prototype")
//        }
//    }
//}

#Preview {
    ContentView()
}

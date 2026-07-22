//
//  LiveMRDemoView.swift
//  AccessibleNavigationDemo
//
//  Created by Marc Lidon on 22/7/26.
//

import Foundation
import SwiftUI

@MainActor
struct LiveMRDemoView: View {

    @State private var statusText = """
    Scanning environment…
    Move the iPhone slowly and point it at the floor.
    """
    @State private var alertText = "Scanning environment"
    @State private var alertLevel: LiveMRAlertLevel = .scanning
    @State private var nearestDistance: Float?
    @State private var resetToken = UUID()

    var body: some View {
        ZStack {
            ARSceneView(
                alertText: $statusText,
                alertLevel: $alertLevel,
                nearestDistance: $nearestDistance,
                statusText: $alertText,
                resetToken: resetToken
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                statusPanel

                Spacer()

                objectLegend

                Button {
                    resetToken = UUID()
                } label: {
                    Label(
                        "Reset Demo",
                        systemImage: "arrow.clockwise"
                    )
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityHint(
                    "Removes the virtual objects and scans the environment again."
                )
            }
            .padding()
        }
        .navigationTitle("Live MR Demo")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statusPanel: some View {
        Text(statusText)
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial)
            .clipShape(
                RoundedRectangle(cornerRadius: 14)
            )
            .accessibilityLabel(statusText)
    }

    private var objectLegend: some View {
        VStack(alignment: .leading, spacing: 8) {
            legendRow(
                color: .red,
                text: "Red cube — Critical risk — P4"
            )

            legendRow(
                color: .orange,
                text: "Orange cube — Obstacle — P3"
            )

            legendRow(
                color: .green,
                text: "Green sphere — Destination — P2"
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
    }

    private func legendRow(
        color: Color,
        text: String
    ) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)
                .accessibilityHidden(true)

            Text(text)
                .font(.caption)
        }
    }
}

#Preview {
    NavigationStack {
        LiveMRDemoView()
    }
}

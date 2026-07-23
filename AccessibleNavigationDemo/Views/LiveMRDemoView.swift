import SwiftUI

@MainActor
struct LiveMRDemoView: View {
    let engine: ScenarioEngine

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
                engine: engine,
                alertText: $alertText,
                alertLevel: $alertLevel,
                nearestDistance: $nearestDistance,
                statusText: $statusText,
                resetToken: resetToken
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                statusPanel
                alertPanel

                Spacer()

                objectLegend

                Button {
                    resetToken = UUID()
                } label: {
                    Label("Reset Demo", systemImage: "arrow.clockwise")
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
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

    private var statusPanel: some View {
        Text(statusText)
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .accessibilityLabel(statusText)
    }

    private var alertPanel: some View {
        HStack(spacing: 12) {
            Image(systemName: alertLevel.systemImage)
                .font(.title2)
                .foregroundStyle(alertLevel.color)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(alertText)
                    .font(.headline)

                if let nearestDistance {
                    Text("Nearest object: \(nearestDistance, specifier: "%.1f") m")
                        .font(.subheadline)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(.regularMaterial)
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(alertLevel.color, lineWidth: 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
    }

    private var objectLegend: some View {
        VStack(alignment: .leading, spacing: 7) {
            legendRow(color: .red, text: "Red cube — Critical risk — P4")
            legendRow(color: .orange, text: "Orange cube — Obstacle — P3")
            legendRow(color: .green, text: "Green sphere — Destination — P2")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func legendRow(color: Color, text: String) -> some View {
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
        LiveMRDemoView(
            engine: ScenarioEngine()
        )
    }
}

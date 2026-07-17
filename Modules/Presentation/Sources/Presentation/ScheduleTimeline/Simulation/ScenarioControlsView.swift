import Domain
import SwiftUI

struct ScenarioControlsView: View {
    let onScenario: (ScheduleSimulationScenario) -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Label("CONFLICT LAB", systemImage: "testtube.2")
                    .font(.system(.caption, design: .rounded, weight: .black))
                    .foregroundStyle(.secondary)
                    .tracking(0.8)
                Spacer()
                Button(action: onReset) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.system(.caption, design: .rounded, weight: .heavy))
                }
                .tint(Color(awanHex: "#FF4B4B"))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    scenarioButton(
                        "Overlap",
                        icon: "square.stack.3d.up.fill",
                        color: "#FF9600",
                        .overlap
                    )
                    scenarioButton(
                        "No room",
                        icon: "hourglass.bottomhalf.filled",
                        color: "#FF4B4B",
                        .zoneOverflow
                    )
                    scenarioButton(
                        "Missed chain",
                        icon: "link.badge.plus",
                        color: "#A560E8",
                        .missedDependencyChain
                    )
                    scenarioButton(
                        "Zone change",
                        icon: "slider.horizontal.3",
                        color: "#1CB0F6",
                        .zoneReconfiguration
                    )
                }
                .padding(.bottom, 6)
            }
        }
    }

    private func scenarioButton(
        _ title: String,
        icon: String,
        color: String,
        _ scenario: ScheduleSimulationScenario
    ) -> some View {
        Button { onScenario(scenario) } label: {
            Label(title, systemImage: icon)
                .font(.system(.caption, design: .rounded, weight: .heavy))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(Color(awanHex: color), in: RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color(awanHex: color).opacity(0.7), radius: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Simulate \(title) conflict")
        .accessibilityIdentifier("scenario-\(scenarioID(scenario))")
    }

    private func scenarioID(_ scenario: ScheduleSimulationScenario) -> String {
        switch scenario {
        case .overlap: "overlap"
        case .zoneOverflow: "overflow"
        case .missedDependencyChain: "missed-chain"
        case .zoneReconfiguration: "zone-change"
        }
    }
}

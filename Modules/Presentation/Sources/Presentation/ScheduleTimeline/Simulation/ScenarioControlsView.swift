import Common
import Domain
import SwiftUI

struct ScenarioControlsView: View {
    let onScenario: (ScheduleSimulationScenario) -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Label("CONFLICT LAB", systemImage: "testtube.2")
                    .font(AppFonts.captionBlack)
                    .foregroundStyle(AppColors.textSecondary)
                    .tracking(0.8)
                Spacer()
                Button(action: onReset) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(AppFonts.captionHeavy)
                }
                .tint(AppColors.destructive)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    scenarioButton(
                        "Overlap",
                        icon: "square.stack.3d.up.fill",
                        color: AppColors.warning,
                        .overlap
                    )
                    scenarioButton(
                        "No room",
                        icon: "hourglass.bottomhalf.filled",
                        color: AppColors.destructive,
                        .zoneOverflow
                    )
                    scenarioButton(
                        "Missed chain",
                        icon: "link.badge.plus",
                        color: AppColors.accentPurple,
                        .missedDependencyChain
                    )
                    scenarioButton(
                        "Zone change",
                        icon: "slider.horizontal.3",
                        color: AppColors.accentBlue,
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
        color: Color,
        _ scenario: ScheduleSimulationScenario
    ) -> some View {
        AppButton(
            title: title,
            icon: icon,
            color: color,
            size: .compact,
            expandsHorizontally: false,
            onTap: { onScenario(scenario) }
        )
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

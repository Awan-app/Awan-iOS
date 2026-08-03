import Common
import SwiftUI

struct DailyZonesContentView: View {
    let viewModel: DailyZonesViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                modePicker
                if viewModel.state.mode == .weekly {
                    DailyZonesWeeklySection(viewModel: viewModel)
                } else {
                    DailyZonesOverrideSection(viewModel: viewModel)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
    }

    private var modePicker: some View {
        AppSegmentedPicker(
            selection: Binding(
                get: { viewModel.state.mode },
                set: { viewModel.send(.selectMode($0)) }
            ),
            items: [
                .init(
                    value: .weekly,
                    title: L10n.Templates.weeklyRoutine,
                    icon: "calendar"
                ),
                .init(
                    value: .override,
                    title: L10n.Templates.dateOverride,
                    icon: "calendar.badge.clock"
                )
            ]
        )
    }
}

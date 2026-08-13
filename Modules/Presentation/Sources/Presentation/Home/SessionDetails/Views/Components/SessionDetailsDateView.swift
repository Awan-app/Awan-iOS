import Common
import SwiftUI

struct SessionDetailsDateView: View {
    let selectedDay: Date
    let isEnabled: Bool
    let onChange: (Date) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.Home.sessionDay)
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.textPrimary)

            AppDatePickerField(
                selection: Binding(
                    get: { selectedDay },
                    set: { newValue in onChange(newValue) }
                ),
                title: L10n.Home.sessionDay,
                in: Date.distantPast...Date.distantFuture
            )
            .disabled(!isEnabled)
        }
    }
}

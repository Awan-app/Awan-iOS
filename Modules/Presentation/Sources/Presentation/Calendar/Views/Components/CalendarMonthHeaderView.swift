import Common
import SwiftUI

struct CalendarMonthHeaderView: View {
    let month: Date
    let locale: Locale
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            navigationButton(
                icon: "chevron.backward",
                accessibilityLabel: L10n.CalendarScreen.previousMonth,
                action: onPreviousMonth
            )

            Spacer()

            Text(
                month.formatted(
                    .dateTime
                        .month(.wide)
                        .year()
                        .locale(locale)
                )
            )
            .font(AppFonts.headlineBlack)
            .foregroundStyle(AppColors.brandDarkBlue)

            Spacer()

            navigationButton(
                icon: "chevron.forward",
                accessibilityLabel: L10n.CalendarScreen.nextMonth,
                action: onNextMonth
            )
        }
    }

    private func navigationButton(
        icon: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(AppFonts.captionIconBlack)
                .foregroundStyle(AppColors.accentBlue)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(
            AppDepthButtonStyle(surfaceColor: AppColors.infoSurface)
        )
        .accessibilityLabel(accessibilityLabel)
    }
}

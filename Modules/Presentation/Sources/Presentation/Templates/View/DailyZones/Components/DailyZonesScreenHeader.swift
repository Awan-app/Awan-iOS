import Common
import SwiftUI

struct DailyZonesScreenHeader: View {
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            AppBackButton(
                accessibilityLabel: L10n.CalendarScreen.back,
                onTap: onBack
            )

            Text(L10n.Templates.dailyZonesTitle)
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .layoutPriority(1)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(AppColors.screenBackground)
    }
}

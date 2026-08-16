import Common
import SwiftUI

struct DailyZonesScreenHeader: View {
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Text(L10n.Templates.dailyZonesTitle)
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)

            HStack {
                AppBackButton(
                    accessibilityLabel: L10n.CalendarScreen.back,
                    onTap: onBack
                )

                Spacer()

                GifImageView("awan-mascot-clock")
                    .frame(width: 64, height: 64)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 64)
        .background(AppColors.screenBackground)
        .zIndex(1)
    }
}

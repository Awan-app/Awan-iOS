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
                Button(action: onBack) {
                    Image(systemName: "chevron.backward")
                        .font(AppFonts.bodyBold)
                        .foregroundStyle(AppColors.accentBlue)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(AppDepthButtonStyle())
                .accessibilityLabel(L10n.CalendarScreen.back)

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

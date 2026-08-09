import Common
import SwiftUI

struct DailyWheelFailureOverlay: View {
    let message: String
    let onRetry: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            AppColors.shadow
                .opacity(0.84)
                .ignoresSafeArea()

            AppDepthSurface(
                surfaceColor: AppColors.surface,
                borderColor: AppColors.warning.opacity(0.42),
                depthColor: AppColors.warning.opacity(0.48)
            ) {
                VStack(spacing: 18) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(AppFonts.heroSymbol)
                        .foregroundStyle(AppColors.warning)

                    Text(L10n.DailyWheel.couldNotLoad)
                        .font(AppFonts.title3Black)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(message)
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)

                    AppButton(
                        title: L10n.DailyWheel.retry,
                        icon: "arrow.clockwise",
                        color: AppColors.accentBlue,
                        onTap: onRetry
                    )

                    Button(L10n.Common.close, action: onClose)
                        .font(AppFonts.bodyBold)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .frame(maxWidth: 330)
            .padding(24)
        }
    }
}

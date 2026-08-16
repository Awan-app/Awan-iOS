import Common
import SwiftUI

struct CategoryLoadFailureView: View {
    let onRetry: () -> Void

    var body: some View {
        AppDepthSurface(
            surfaceColor: AppColors.warningSurface,
            borderColor: AppColors.warning.opacity(0.34),
            depthColor: AppColors.warning.opacity(0.42)
        ) {
            VStack(spacing: 16) {
                Text(L10n.Profile.loadFailure)
                    .font(AppFonts.bodySemibold)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)

                AppButton(
                    title: L10n.Home.retry,
                    color: AppColors.accentBlue,
                    onTap: onRetry
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
}

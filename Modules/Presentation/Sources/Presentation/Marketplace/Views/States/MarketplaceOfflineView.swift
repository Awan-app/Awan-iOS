import Common
import SwiftUI

struct MarketplaceOfflineView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image("MarketplaceOffline", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(L10n.Marketplace.offlineTitle)
                    .font(AppFonts.titleBlack)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(L10n.Marketplace.offlineMessage)
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            AppButton(
                title: L10n.Marketplace.retry,
                icon: "arrow.clockwise",
                color: AppColors.accentBlue,
                size: .regular,
                expandsHorizontally: false,
                onTap: onRetry
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

#Preview("Marketplace Offline Light") {
    MarketplaceOfflineView(onRetry: {})
        .padding()
        .background(AppColors.screenBackground)
        .preferredColorScheme(.light)
}

#Preview("Marketplace Offline Dark") {
    MarketplaceOfflineView(onRetry: {})
        .padding()
        .background(AppColors.screenBackground)
        .preferredColorScheme(.dark)
}

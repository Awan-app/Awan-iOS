import Common
import SwiftUI

struct MarketplaceDetailAffordableCard: View {
    let pts: Int
    let userPoints: Int

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 22),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.outline.opacity(0.12),
            depthColor: AppColors.outline.opacity(0.16),
            borderWidth: 1.5, depthOffset: 5,
            contentInsets: EdgeInsets(top: 18, leading: 18, bottom: 20, trailing: 18)
        ) {
            VStack(alignment: .leading, spacing: 18) {
                MarketplaceDetailPriceRow(pts: pts, userPoints: userPoints, highlightYouHave: false)

                Divider().opacity(0.4)

                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "cloud")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(AppColors.accentBlue)
                        .frame(width: 42, height: 42)
                        .background(
                            Circle()
                                .stroke(AppColors.accentBlue.opacity(0.35), lineWidth: 1.5)
                                .background(Circle().fill(AppColors.accentBlue.opacity(0.06)))
                        )
                    VStack(alignment: .leading, spacing: 3) {
                        Text(L10n.Marketplace.notOwned)
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(L10n.Marketplace.notOwnedDesc)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                AppButton(
                    title: "\(L10n.Marketplace.buyFor) \(pts) \(L10n.Marketplace.pts)",
                    icon: "star.fill",
                    iconColor: AppColors.reward,
                    color: AppColors.accentBlue,
                    size: .large, onTap: {}
                )

                HStack(spacing: 6) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.accentBlue)
                    Text(L10n.Marketplace.oncePurchased)
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

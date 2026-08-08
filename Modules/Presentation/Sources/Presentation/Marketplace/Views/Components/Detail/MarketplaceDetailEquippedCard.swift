import Common
import SwiftUI

struct MarketplaceDetailEquippedCard: View {
    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 22),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.accentBlue.opacity(0.30),
            depthColor: AppColors.accentBlueDepth.opacity(0.35),
            borderWidth: 1.5, depthOffset: 5,
            contentInsets: EdgeInsets(top: 18, leading: 18, bottom: 20, trailing: 18)
        ) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppColors.accentBlue.opacity(0.10))
                            .frame(width: 44, height: 44)
                        Circle()
                            .stroke(AppColors.accentBlue.opacity(0.30), lineWidth: 2)
                            .frame(width: 44, height: 44)
                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(AppColors.accentBlue)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(L10n.Marketplace.currentlyEquipped)
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.accentBlue)
                        Text(L10n.Marketplace.equippedHint)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppColors.infoSurface)
                )

                AppButton(
                    title: L10n.Marketplace.currentlyEquipped,
                    icon: "checkmark",
                    color: AppColors.accentBlue,
                    size: .large, onTap: {}
                )
            }
        }
    }
}

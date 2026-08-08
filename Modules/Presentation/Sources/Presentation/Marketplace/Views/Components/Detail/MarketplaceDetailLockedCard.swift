import Common
import SwiftUI

struct MarketplaceDetailLockedCard: View {
    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 22),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.outline.opacity(0.18),
            depthColor: AppColors.outline.opacity(0.15),
            borderWidth: 1.5, depthOffset: 5,
            contentInsets: EdgeInsets(top: 18, leading: 18, bottom: 20, trailing: 18)
        ) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppColors.outline.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(L10n.Marketplace.statusLocked)
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(L10n.Marketplace.lockedHint)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppColors.outline.opacity(0.06))
                )

                AppButton(
                    title: L10n.Marketplace.statusLocked,
                    icon: "lock.fill",
                    color: AppColors.buttonDisabled,
                    foregroundColor: AppColors.textSecondary,
                    shadowColor: AppColors.buttonDisabledDepth,
                    size: .large, onTap: {}
                )
            }
        }
    }
}

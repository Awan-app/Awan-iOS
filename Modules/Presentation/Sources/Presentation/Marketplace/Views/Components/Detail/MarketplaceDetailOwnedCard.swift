import Common
import SwiftUI

struct MarketplaceDetailOwnedCard: View {
    var isEquipping: Bool = false
    var onEquip: () -> Void = {}

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 22),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.accentGreen.opacity(0.35),
            depthColor: AppColors.accentGreenDepth.opacity(0.40),
            borderWidth: 1.5, depthOffset: 5,
            contentInsets: EdgeInsets(top: 18, leading: 18, bottom: 20, trailing: 18)
        ) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppColors.accentGreen.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(AppColors.accentGreen)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(L10n.Marketplace.itsYours)
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.accentGreen)
                        Text(L10n.Marketplace.ownedHint)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppColors.accentGreen.opacity(0.06))
                )

                if isEquipping {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 48)
                } else {
                    AppButton(
                        title: L10n.Marketplace.equip,
                        icon: "wand.and.sparkles",
                        color: AppColors.accentGreen,
                        size: .large,
                        onTap: onEquip
                    )
                }
            }
        }
    }
}

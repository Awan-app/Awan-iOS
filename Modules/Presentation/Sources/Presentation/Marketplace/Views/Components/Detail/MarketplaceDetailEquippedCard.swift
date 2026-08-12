import Common
import SwiftUI

struct MarketplaceDetailEquippedCard: View {
    var isUnequipping: Bool = false
    var onUnequip: (() -> Void)? = nil

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 22),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.accentBlue.opacity(0.30),
            depthColor: AppColors.accentBlueDepth.opacity(0.35),
            borderWidth: 1.5, depthOffset: 5,
            contentInsets: EdgeInsets(top: 18, leading: 18, bottom: 20, trailing: 18)
        ) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppColors.accentBlue)
                            .frame(width: 42, height: 42)
                        Image(systemName: "checkmark")
                            .font(.system(size: 17, weight: .black))
                            .foregroundStyle(AppColors.onAccent)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Marketplace.currentlyEquipped)
                            .font(AppFonts.headlineBlack)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Text(L10n.Marketplace.equippedHint)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if let onUnequip {
                    Divider()
                        .overlay(AppColors.accentBlue.opacity(0.18))

                    AppButton(
                        title: L10n.Marketplace.unequip,
                        icon: "xmark",
                        color: AppColors.destructive,
                        size: .large,
                        isLoading: isUnequipping,
                        onTap: onUnequip
                    )
                }
            }
        }
    }
}

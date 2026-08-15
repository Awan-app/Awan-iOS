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
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppColors.accentGreen)
                            .frame(width: 42, height: 42)
                        Image(systemName: "checkmark")
                            .font(.system(size: 17, weight: .black))
                            .foregroundStyle(AppColors.onAccent)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Marketplace.itsYours)
                            .font(AppFonts.headlineBlack)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Text(L10n.Marketplace.ownedHint)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()
                    .overlay(AppColors.accentGreen.opacity(0.18))

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

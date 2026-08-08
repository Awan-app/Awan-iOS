import Common
import SwiftUI

struct InventoryPlaceholderView: View {
    var body: some View {
        ZStack {
            AppColors.screenBackground
                .ignoresSafeArea()

            AppDepthSurface(
                surfaceColor: AppColors.infoSurface,
                borderColor: AppColors.accentPurple.opacity(0.28),
                depthColor: AppColors.accentPurple.opacity(0.38)
            ) {
                VStack(spacing: 14) {
                    Image(systemName: "shippingbox.fill")
                        .font(AppFonts.heroSymbol)
                        .foregroundStyle(AppColors.accentPurple)

                    Text(L10n.Profile.inventory)
                        .font(AppFonts.titleBlack)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(L10n.Profile.inventoryPlaceholder)
                        .font(AppFonts.bodySemibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(24)
        }
        .navigationTitle(L10n.Profile.inventory)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Inventory Placeholder Light") {
    NavigationStack {
        InventoryPlaceholderView()
    }
}

#Preview("Inventory Placeholder Dark") {
    NavigationStack {
        InventoryPlaceholderView()
    }
    .preferredColorScheme(.dark)
}

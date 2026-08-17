import Common
import SwiftUI

struct InventoryPlaceholderView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        ZStack {
            AppColors.screenBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    AppBackButton(
                        accessibilityLabel: L10n.CalendarScreen.back,
                        onTap: { coordinator.mainCoordinator.pop() }
                    )

                    Text(L10n.Profile.inventory)
                        .font(AppFonts.title3Black)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .layoutPriority(1)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .background(AppColors.screenBackground)

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

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
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

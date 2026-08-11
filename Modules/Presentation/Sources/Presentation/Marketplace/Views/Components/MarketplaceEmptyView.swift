import Common
import SwiftUI

struct MarketplaceEmptyView: View {
    var body: some View {
        VStack(spacing: 8) {
            AwanMascotView(state: .normal)
                .frame(width: 140, height: 110)

            Text(L10n.Marketplace.emptyTitle)
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.top, 4)

            Text(L10n.Marketplace.emptySubtitle)
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.top, 30)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity)
    }
}

#Preview("Marketplace Empty View") {
    MarketplaceEmptyView()
        .background(AppColors.screenBackground)
}

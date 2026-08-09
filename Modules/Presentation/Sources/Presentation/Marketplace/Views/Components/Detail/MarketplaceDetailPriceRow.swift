import Common
import SwiftUI

struct MarketplaceDetailPriceRow: View {
    let pts: Int
    let userPoints: Int
    let highlightYouHave: Bool

    var body: some View {
        HStack(spacing: 0) {
            column(label: L10n.Marketplace.priceLabel, value: pts, red: false)
            Spacer(minLength: 32)
            Divider().frame(width: 1, height: 36)
            Spacer(minLength: 32)
            column(label: L10n.Marketplace.youHave, value: userPoints, red: highlightYouHave)
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func column(label: String, value: Int, red: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AppFonts.caption2Bold)
                .foregroundStyle(AppColors.textSecondary)
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(AppColors.reward)
                Text("\(value)")
                    .font(AppFonts.title3Black)
                    .foregroundStyle(red ? AppColors.destructive : AppColors.textPrimary)
            }
        }
    }
}

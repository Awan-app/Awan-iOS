import Common
import SwiftUI

struct MarketplacePointsCard: View {
    let points: Int

    @Environment(LanguageManager.self) private var languageManager

    private var formattedPoints: String {
        points.formatted(.number.locale(languageManager.locale))
    }

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 24),
            surfaceColor: AppColors.infoSurface,
            borderColor: AppColors.accentBlue.opacity(0.22),
            depthColor: AppColors.accentBlueDepth.opacity(0.28),
            borderWidth: 1.5,
            depthOffset: 5,
            contentInsets: EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 18)
        ) {
            ZStack(alignment: .trailing) {
                Image(systemName: "sparkles")
                    .font(.system(size: 38, weight: .black))
                    .foregroundStyle(AppColors.accentBlue.opacity(0.12))
                    .padding(.trailing, 4)

                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 24, weight: .black))
                                .foregroundStyle(AppColors.accentBlue)

                            Text("\(formattedPoints) \(L10n.Marketplace.pts)")
                                .font(AppFonts.title2Black)
                                .foregroundStyle(AppColors.accentBlue)
                        }

                        Text(L10n.Marketplace.pointsSubtitle)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview("Points Card Light") {
    MarketplacePointsCard(points: 1_240)
        .padding()
        .background(AppColors.screenBackground)
        .environment(LanguageManager())
}

#Preview("Points Card Dark") {
    MarketplacePointsCard(points: 1_240)
        .padding()
        .background(AppColors.screenBackground)
        .environment(LanguageManager())
        .preferredColorScheme(.dark)
}

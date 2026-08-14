import Common
import SwiftUI

struct MarketplaceDetailNotEnoughCard: View {
    let pts: Int
    let userPoints: Int

    private var deficit: Int { max(0, pts - userPoints) }
    private var progress: Double { min(1.0, Double(userPoints) / Double(pts)) }

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 22),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.warning.opacity(0.35),
            depthColor: AppColors.warning.opacity(0.30),
            borderWidth: 1.5, depthOffset: 5,
            contentInsets: EdgeInsets(top: 18, leading: 18, bottom: 20, trailing: 18)
        ) {
            VStack(alignment: .leading, spacing: 18) {
                MarketplaceDetailPriceRow(pts: pts, userPoints: userPoints, highlightYouHave: true)

                progressSection

                Divider().opacity(0.4)

                HStack(spacing: 10) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppColors.warning)
                    Text(L10n.Marketplace.earnMoreHint)
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                AppButton(
                    title: "\(L10n.Marketplace.buyFor) \(pts) \(L10n.Marketplace.pts)",
                    icon: "star.fill",
                    iconColor: AppColors.reward.opacity(0.5),
                    color: AppColors.buttonDisabled,
                    foregroundColor: AppColors.textSecondary.opacity(0.7),
                    shadowColor: AppColors.buttonDisabledDepth,
                    size: .large, onTap: {}
                )
            }
        }
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(L10n.Marketplace.progressLabel)
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(AppColors.warning)
                    Text(L10n.Marketplace.needMorePts(deficit))
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(AppColors.warning)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(AppColors.warning.opacity(0.12)))
                .overlay(Capsule().stroke(AppColors.warning.opacity(0.35), lineWidth: 1.2))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColors.outline.opacity(0.16))
                        .frame(height: 7)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.warning.opacity(0.85), AppColors.warning],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 7)
                }
            }
            .frame(height: 7)
        }
    }
}

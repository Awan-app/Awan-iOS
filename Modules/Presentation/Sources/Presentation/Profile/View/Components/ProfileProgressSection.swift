import Common
import SwiftUI

struct ProfileProgressSection: View {
    let points: Int
    let streak: Int
    let onInventoryTap: () -> Void

    @Environment(LanguageManager.self) private var languageManager

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: columns, spacing: 12) {
                statCard(
                    icon: "star.fill",
                    watermarkFont: AppFonts.goalHeroSymbol,
                    value: points,
                    title: L10n.Profile.points,
                    color: AppColors.reward,
                    surfaceColor: AppColors.infoSurface
                )

                statCard(
                    icon: "flame.fill",
                    watermarkFont: AppFonts.profileStatWatermark,
                    value: streak,
                    title: L10n.Profile.streak,
                    color: AppColors.warning,
                    surfaceColor: AppColors.warningSurface
                )
            }

            Button(action: onInventoryTap) {
                HStack(spacing: 14) {
                    Image(systemName: "shippingbox.fill")
                        .font(AppFonts.progressSymbol)
                        .foregroundStyle(AppColors.accentPurple)
                        .frame(width: 42, height: 42)
                        .background(
                            AppColors.accentPurple.opacity(0.12),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(L10n.Profile.inventory)
                            .font(AppFonts.headlineBlack)
                            .foregroundStyle(AppColors.textPrimary)

                        Text(L10n.Profile.inventorySubtitle)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.forward")
                        .font(AppFonts.captionIconBlack)
                        .foregroundStyle(AppColors.accentPurple)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, minHeight: 76)
                .contentShape(Rectangle())
            }
            .buttonStyle(
                AppDepthButtonStyle(
                    shape: .roundedRectangle(cornerRadius: 20),
                    surfaceColor: AppColors.surface,
                    borderColor: AppColors.accentPurple.opacity(0.30),
                    depthColor: AppColors.accentPurple.opacity(0.38),
                    depthOffset: 5
                )
            )
            .accessibilityHint(L10n.Profile.inventorySubtitle)
        }
    }

    private func statCard(
        icon: String,
        watermarkFont: Font,
        value: Int,
        title: String,
        color: Color,
        surfaceColor: Color
    ) -> some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 20),
            surfaceColor: surfaceColor,
            borderColor: color.opacity(0.34),
            depthColor: color.opacity(0.52),
            depthOffset: 5,
            contentInsets: EdgeInsets()
        ) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(color.opacity(0.13))
                    .frame(width: 106, height: 106)
                    .offset(x: 42, y: -48)

                Image(systemName: icon)
                    .font(watermarkFont)
                    .foregroundStyle(color.opacity(0.07))
                    .rotationEffect(.degrees(-12))
                    .offset(x: 20, y: 62)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .center) {
                        Image(systemName: icon)
                            .font(AppFonts.progressSymbol)
                            .foregroundStyle(color)
                            .frame(width: 38, height: 38)
                            .background(
                                AppColors.surface.opacity(0.88),
                                in: RoundedRectangle(
                                    cornerRadius: 12,
                                    style: .continuous
                                )
                            )
                            .overlay {
                                RoundedRectangle(
                                    cornerRadius: 12,
                                    style: .continuous
                                )
                                .stroke(color.opacity(0.22), lineWidth: 1)
                            }

                        Text(title)
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                    }

                    Text(value.formatted(.number.locale(languageManager.locale)))
                        .font(AppFonts.profileStatNumber)
                        .foregroundStyle(AppColors.textPrimary)
                        .minimumScaleFactor(0.72)
                        .lineLimit(1)
                        .contentTransition(.numericText(value: Double(value)))
                }
                .padding(14)
            }
            .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
            .clipShape(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value.formatted(.number.locale(languageManager.locale)))
    }
}

#Preview("Profile Progress Light") {
    ProfileProgressSection(points: 1_240, streak: 6, onInventoryTap: {})
        .padding()
        .background(AppColors.screenBackground)
        .environment(LanguageManager())
}

#Preview("Profile Progress Dark") {
    ProfileProgressSection(points: 1_240, streak: 6, onInventoryTap: {})
        .padding()
        .background(AppColors.screenBackground)
        .environment(LanguageManager())
        .preferredColorScheme(.dark)
}

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
                    value: points,
                    title: L10n.Profile.points,
                    color: AppColors.reward,
                    surfaceColor: AppColors.infoSurface
                )

                statCard(
                    icon: "flame.fill",
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
        value: Int,
        title: String,
        color: Color,
        surfaceColor: Color
    ) -> some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 20),
            surfaceColor: surfaceColor,
            borderColor: color.opacity(0.34),
            depthColor: color.opacity(0.42),
            depthOffset: 5,
            contentInsets: EdgeInsets(top: 18, leading: 16, bottom: 18, trailing: 16)
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(AppFonts.progressSymbol)
                    .foregroundStyle(color)

                Text(value.formatted(.number.locale(languageManager.locale)))
                    .font(AppFonts.titleBlack)
                    .foregroundStyle(AppColors.textPrimary)
                    .contentTransition(.numericText(value: Double(value)))

                Text(title)
                    .font(AppFonts.subheadlineBold)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
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

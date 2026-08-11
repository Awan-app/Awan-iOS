import Common
import SwiftUI

struct ProfileProgressSection: View {
    let points: Int
    let streak: Int
    let maxStreak: Int

    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 12) {
                    cards
                }
            } else {
                HStack(alignment: .top, spacing: 10) {
                    cards
                }
            }
        }
    }

    @ViewBuilder
    private var cards: some View {
        statItem(
            symbol: .system("flame.fill"),
            value: streak,
            title: L10n.Profile.streak,
            color: AppColors.warning,
            surfaceColor: AppColors.warningSurface
        )

        statItem(
            symbol: .animatedFire,
            value: maxStreak,
            title: L10n.Profile.maxStreak,
            color: AppColors.warning,
            surfaceColor: AppColors.surface
        )

        statItem(
            symbol: .system("star.fill"),
            value: points,
            title: L10n.Profile.points,
            color: AppColors.reward,
            surfaceColor: AppColors.surface
        )
    }

    private func statItem(
        symbol: StatSymbol,
        value: Int,
        title: String,
        color: Color,
        surfaceColor: Color
    ) -> some View {
        VStack(spacing: 5) {
            AppDepthSurface(
                shape: .circle,
                surfaceColor: surfaceColor,
                borderColor: color.opacity(0.34),
                depthColor: color.opacity(0.52),
                depthOffset: 4,
                contentInsets: EdgeInsets()
            ) {
                symbolView(symbol, color: color)
                    .frame(width: 27, height: 27)
                    .frame(width: 52, height: 52)
            }

            Text(value.formatted(.number.locale(languageManager.locale)))
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .contentTransition(.numericText(value: Double(value)))

            Text(title)
                .font(AppFonts.caption2Bold)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, 2)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value.formatted(.number.locale(languageManager.locale)))
    }

    @ViewBuilder
    private func symbolView(_ symbol: StatSymbol, color: Color) -> some View {
        switch symbol {
        case let .system(name):
            Image(systemName: name)
                .resizable()
                .scaledToFit()
                .foregroundStyle(color)
                .padding(3)
        case .animatedFire:
            StreakFireView()
        }
    }
}

private enum StatSymbol {
    case system(String)
    case animatedFire
}

#Preview("Profile Progress Light") {
    ProfileProgressSection(points: 1_240, streak: 6, maxStreak: 18)
        .padding()
        .background(AppColors.screenBackground)
        .environment(LanguageManager())
}

#Preview("Profile Progress Dark") {
    ProfileProgressSection(points: 1_240, streak: 6, maxStreak: 18)
        .padding()
        .background(AppColors.screenBackground)
        .environment(LanguageManager())
        .preferredColorScheme(.dark)
}

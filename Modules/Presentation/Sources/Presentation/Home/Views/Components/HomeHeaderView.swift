import Common
import SwiftUI

struct HomeHeaderView: View {
    let displayName: String?
    let streakCount: Int
    let rewardPoints: Int
    let pointsPulse: Int
    let isCollapsed: Bool
    
    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 7) {
                if !isCollapsed {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(greetingPrefix + (hasDisplayName ? "," : ""))
                            .font(AppFonts.title3Black)
                            .foregroundStyle(AppColors.brandDarkBlue)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                        if let displayName, !displayName.isEmpty {
                            Text(displayName)
                                .font(AppFonts.title3Black)
                                .foregroundStyle(AppColors.brandDarkBlue)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                        }
                    }
                    .transition(
                        .opacity.combined(
                            with: .scale(scale: 0.96, anchor: .topLeading)
                        )
                    )
                }

                HStack(spacing: 10) {
                    RewardStatChip(
                        icon: "flame.fill",
                        value: streakCount.formatted(
                            .number.locale(languageManager.locale)
                        ),
                        color: AppColors.warning,
                        isCompact: true
                    )
                    RewardStatChip(
                        icon: "star.fill",
                        value: rewardPoints.formatted(
                            .number.locale(languageManager.locale)
                        ),
                        color: AppColors.reward,
                        isCompact: true
                    )
                    .symbolEffect(.bounce, value: pointsPulse)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .anchorPreference(
                                    key: RewardAnchorKey.self,
                                    value: .bounds
                                ) { ["points-badge": $0] }
                        }
                    )
                }
            }

            Spacer(minLength: 4)

            AwanMascotView()
                .frame(width: 96, height: 78)
                .scaleEffect(isCollapsed ? 2 / 3 : 1)
                .frame(
                    width: isCollapsed ? 64 : 96,
                    height: isCollapsed ? 52 : 78
                )
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(
            .spring(response: 0.26, dampingFraction: 0.9),
            value: isCollapsed
        )
    }

    private var greetingPrefix: String {
        let hour = languageManager.calendar.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return L10n.Home.goodMorning
        case 12..<17:
            return L10n.Home.goodAfternoon
        default:
            return L10n.Home.goodEvening
        }
    }

    private var hasDisplayName: Bool {
        displayName?.isEmpty == false
    }
}

#Preview {
    HomeHeaderView(
        displayName: "Andrew",
        streakCount: 5,
        rewardPoints: 100,
        pointsPulse: 0,
        isCollapsed: false
    )
        .padding()
        .environment(LanguageManager())
}

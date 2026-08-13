import Common
import SwiftUI

struct HomeHeaderView: View {
    let displayName: String?
    let streakCount: Int
    let rewardPoints: Int
    let pointsPulse: Int
    
    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(greetingPrefix + (hasDisplayName ? "," : ""))
                        .font(AppFonts.titleBlack)
                        .foregroundStyle(AppColors.brandDarkBlue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    if let displayName, !displayName.isEmpty {
                        Text(displayName)
                            .font(AppFonts.titleBlack)
                            .foregroundStyle(AppColors.brandDarkBlue)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                }

                HStack(spacing: 10) {
                    RewardStatChip(
                        icon: "flame.fill",
                        value: streakCount.formatted(
                            .number.locale(languageManager.locale)
                        ),
                        color: AppColors.warning
                    )
                    RewardStatChip(
                        icon: "star.fill",
                        value: rewardPoints.formatted(
                            .number.locale(languageManager.locale)
                        ),
                        color: AppColors.reward
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
                .frame(width: 96, height: 96)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        pointsPulse: 0
    )
        .padding()
        .environment(LanguageManager())
}

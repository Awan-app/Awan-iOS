import Common
import SwiftUI

struct HomeHeaderView: View {
    let displayName: String?
    let selectedDay: Date
    let streakCount: Int
    let rewardPoints: Int

    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(greeting)
                        .font(AppFonts.titleBlack)
                        .foregroundStyle(AppColors.brandDarkBlue)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)

                    HStack(spacing: 10) {
                        HomeStatChip(
                            icon: "flame.fill",
                            value: streakCount.formatted(.number.locale(languageManager.locale)),
                            color: AppColors.warning
                        )
                        HomeStatChip(
                            icon: "star.fill",
                            value: rewardPoints.formatted(.number.locale(languageManager.locale)),
                            color: AppColors.reward
                        )
                    }
                }

                Spacer(minLength: 4)

                AwanMascotView()
                    .frame(width: 76, height: 76)
                    .shadow(color: AppColors.shadow.opacity(0.12), radius: 10, y: 5)
            }

            Text(selectedDay.formatted(.dateTime.weekday(.wide).month(.wide).day().locale(languageManager.locale)))
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)
        }
    }

    private var greeting: String {
        let hour = languageManager.calendar.component(.hour, from: Date())
        let base: String
        switch hour {
        case 5..<12:
            base = L10n.Home.goodMorning
        case 12..<17:
            base = L10n.Home.goodAfternoon
        default:
            base = L10n.Home.goodEvening
        }
        guard let displayName, !displayName.isEmpty else { return base }
        return "\(base), \(displayName)"
    }
}

private struct HomeStatChip: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(AppFonts.statSymbol)
            Text(value)
                .font(AppFonts.headlineBlack)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.42), lineWidth: 1.5)
        }
        .shadow(color: color.opacity(0.28), radius: 0, y: 3)
    }
}

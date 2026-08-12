import Common
import SwiftUI

struct HomeHeaderView: View {
    let displayName: String?
    let selectedDay: Date
    let streakCount: Int
    let rewardPoints: Int
    let onOpenCalendar: () -> Void
    let onSelectToday: () -> Void
    let pointsPulse: Int
    
    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            greetingHero

            dateHeader
        }
    }

    private var greetingHero: some View {
        AppDepthSurface(
            surfaceColor: AppColors.infoSurface,
            borderColor: AppColors.accentBlue.opacity(0.22),
            depthColor: AppColors.accentBlueDepth.opacity(0.28),
            contentInsets: EdgeInsets()
        ) {
            ZStack(alignment: .topTrailing) {
                heroDecorations

                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(greeting)
                            .font(AppFonts.titleBlack)
                            .foregroundStyle(AppColors.brandDarkBlue)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)

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
                        .frame(width: 82, height: 82)
                        .shadow(
                            color: AppColors.accentBlueDepth.opacity(0.16),
                            radius: 10,
                            y: 6
                        )
                }
                .padding(18)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipShape(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
        }
    }

    private var heroDecorations: some View {
        ZStack {
            Circle()
                .fill(AppColors.accentBlue.opacity(0.10))
                .frame(width: 142, height: 142)
                .offset(x: 46, y: -58)

            Circle()
                .fill(AppColors.reward.opacity(0.14))
                .frame(width: 42, height: 42)
                .offset(x: -78, y: 22)

            Image(systemName: "sparkles")
                .font(AppFonts.tabSymbol)
                .foregroundStyle(AppColors.accentBlue.opacity(0.38))
                .offset(x: -112, y: 82)
        }
        .accessibilityHidden(true)
    }

    private var dateHeader: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(AppColors.accentBlue.gradient)
                .frame(width: 5, height: 30)

            Text(
                selectedDay.formatted(
                    .dateTime
                        .weekday(.wide)
                        .month(.wide)
                        .day()
                        .locale(languageManager.locale)
                )
            )
            .font(AppFonts.title3Black)
            .foregroundStyle(AppColors.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.72)

            Spacer(minLength: 4)

            if !languageManager.calendar.isDateInToday(selectedDay) {
                Button(action: onSelectToday) {
                    Label(
                        L10n.CalendarScreen.jumpToPresent,
                        systemImage: "arrow.uturn.backward"
                    )
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.accentBlue)
                    .padding(.horizontal, 10)
                    .frame(height: 34)
                }
                .buttonStyle(
                    AppDepthButtonStyle(
                        shape: .capsule,
                        borderColor: AppColors.accentBlue.opacity(0.55),
                        depthColor: AppColors.accentBlueDepth
                    )
                )
                .transition(.scale.combined(with: .opacity))
            }

            dateActionButton(
                icon: "calendar",
                accessibilityLabel: L10n.Home.calendar,
                action: onOpenCalendar
            )
        }
        .animation(
            .spring(response: 0.38, dampingFraction: 0.84),
            value: languageManager.calendar.isDateInToday(selectedDay)
        )
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

    private func dateActionButton(
        icon: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(AppFonts.captionIconBlack)
                .foregroundStyle(AppColors.accentBlue)
                .frame(width: 34, height: 34)
        }
        .buttonStyle(
            AppDepthButtonStyle(
                shape: .circle,
                borderColor: AppColors.accentBlue.opacity(0.55),
                depthColor: AppColors.accentBlueDepth
            )
        )
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    HomeHeaderView(
        displayName: "Andrew",
        selectedDay: Date(),
        streakCount: 5,
        rewardPoints: 100,
        onOpenCalendar: {},
        onSelectToday: {},
        pointsPulse: 0
    )
        .padding()
        .environment(LanguageManager())
}

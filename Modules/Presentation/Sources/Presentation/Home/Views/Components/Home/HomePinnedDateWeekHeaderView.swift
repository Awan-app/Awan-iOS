import Common
import SwiftUI

struct HomePinnedDateWeekHeaderView: View {
    let selectedDay: Date
    let onSelect: (Date) -> Void
    let onOpenCalendar: () -> Void
    let onSelectToday: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HomeDateRowView(
                selectedDay: selectedDay,
                onOpenCalendar: onOpenCalendar,
                onSelectToday: onSelectToday
            )

            HomeWeekStripView(
                selectedDay: selectedDay,
                onSelect: onSelect
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 2)
        .padding(.bottom, 8)
        .background(AppColors.screenBackground)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppColors.outline.opacity(0.08))
                .frame(height: 1)
        }
    }
}

private struct HomeDateRowView: View {
    let selectedDay: Date
    let onOpenCalendar: () -> Void
    let onSelectToday: () -> Void

    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
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
                HomeTodayButton(action: onSelectToday)
                    .transition(.scale.combined(with: .opacity))
            }

            HomeCalendarButton(action: onOpenCalendar)
        }
        .animation(
            .spring(response: 0.38, dampingFraction: 0.84),
            value: languageManager.calendar.isDateInToday(selectedDay)
        )
    }
}

private struct HomeTodayButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
    }
}

private struct HomeCalendarButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "calendar")
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
        .accessibilityLabel(L10n.Home.calendar)
    }
}

#Preview {
    HomePinnedDateWeekHeaderView(
        selectedDay: Date(),
        onSelect: { _ in },
        onOpenCalendar: {},
        onSelectToday: {}
    )
    .environment(LanguageManager())
}

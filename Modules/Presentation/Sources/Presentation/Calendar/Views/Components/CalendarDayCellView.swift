import Common
import SwiftUI

struct CalendarDayCellView: View {
    let cell: CalendarDayCell
    let isSelected: Bool
    let isToday: Bool
    let isActivity: Bool
    let deadlineCount: Int
    let locale: Locale
    let onSelectDate: (Date) -> Void

    var body: some View {
        Button {
            onSelectDate(cell.date)
        } label: {
            ZStack {
                if isSelected {
                    selectedDayBackground
                }

                Text(
                    cell.date.formatted(
                        .dateTime
                            .day()
                            .locale(locale)
                    )
                )
                .font(AppFonts.subheadlineBlack)
                .foregroundStyle(dayForeground)

                if isActivity {
                    CalendarStreakBadge()
                        .offset(x: 13, y: -13)
                }

                if deadlineCount > 0 {
                    Circle()
                        .fill(AppColors.destructive.opacity(0.72))
                        .frame(
                            width: CalendarMonthLayout.deadlineDotSize,
                            height: CalendarMonthLayout.deadlineDotSize
                        )
                        .offset(y: 22)
                }
            }
            .frame(width: 40, height: 40)
            .overlay {
                if isToday, !isSelected, !isActivity {
                    Circle()
                        .stroke(
                            AppColors.accentBlue.opacity(0.7),
                            lineWidth: 1.5
                        )
                        .frame(
                            width: CalendarMonthLayout.selectedDaySize,
                            height: CalendarMonthLayout.selectedDaySize
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: CalendarMonthLayout.dayRowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            cell.date.formatted(
                Date.FormatStyle(
                    date: .complete,
                    time: .omitted,
                    locale: locale
                )
            )
        )
        .accessibilityValue(accessibilityValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var selectedDayBackground: some View {
        ZStack {
            Circle()
                .fill(AppColors.accentBlueDepth)
                .frame(
                    width: CalendarMonthLayout.selectedDaySize,
                    height: CalendarMonthLayout.selectedDaySize
                )
                .offset(y: 3)

            Circle()
                .fill(AppColors.accentBlue.gradient)
                .frame(
                    width: CalendarMonthLayout.selectedDaySize,
                    height: CalendarMonthLayout.selectedDaySize
                )
        }
    }

    private var dayForeground: Color {
        if isSelected {
            return AppColors.onAccent
        }

        if !cell.isInDisplayedMonth {
            return AppColors.textSecondary.opacity(0.23)
        }

        return AppColors.textPrimary
    }

    private var accessibilityValue: String {
        var values: [String] = []

        if isActivity {
            values.append(L10n.CalendarScreen.streakDay)
        }

        if deadlineCount > 0 {
            values.append(L10n.CalendarScreen.hasDeadline)
        }

        return values.joined(separator: ", ")
    }
}

private struct CalendarStreakBadge: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.surface)
                .frame(width: 18, height: 18)

            Image(systemName: "flame.fill")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(AppColors.streakGradient)
        }
        .accessibilityHidden(true)
    }
}

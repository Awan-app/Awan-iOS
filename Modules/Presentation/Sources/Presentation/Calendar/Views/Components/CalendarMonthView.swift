import Common
import SwiftUI

struct CalendarMonthView: View {
    let month: Date
    let selectedDate: Date
    let goals: [CalendarGoalUIModel]
    let navigationDirection: CalendarMonthNavigationDirection
    let onSelectDate: (Date) -> Void
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void

    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.layoutDirection) private var layoutDirection

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 4),
        count: 7
    )

    var body: some View {
        AppDepthSurface(
            contentInsets: EdgeInsets(
                top: 14,
                leading: 14,
                bottom: 14,
                trailing: 14
            )
        ) {
            VStack(spacing: 11) {
                monthHeader
                weekdayHeader

                ZStack {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(Array(dates.enumerated()), id: \.offset) { _, date in
                            if let date {
                                dayButton(date)
                            } else {
                                Color.clear
                                    .frame(height: 36)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                    .id(month)
                    .transition(dayGridTransition)
                    .padding(.bottom, 4)
                }
                .contentShape(Rectangle())
                .simultaneousGesture(monthSwipeGesture)
                .clipped()
                .animation(
                    reduceMotion
                        ? nil
                        : .spring(response: 0.42, dampingFraction: 0.86),
                    value: month
                )
            }
        }
    }

    private var monthHeader: some View {
        HStack(spacing: 12) {
            monthButton(
                icon: "chevron.backward",
                accessibilityLabel: L10n.CalendarScreen.previousMonth,
                action: onPreviousMonth
            )

            Spacer()

            Text(
                month.formatted(
                    .dateTime
                        .month(.wide)
                        .year()
                        .locale(languageManager.locale)
                )
            )
            .font(AppFonts.headlineBlack)
            .foregroundStyle(AppColors.brandDarkBlue)

            Spacer()

            monthButton(
                icon: "chevron.forward",
                accessibilityLabel: L10n.CalendarScreen.nextMonth,
                action: onNextMonth
            )
        }
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .accessibilityHidden(true)
    }

    private func dayButton(_ date: Date) -> some View {
        let calendar = languageManager.calendar
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let deadlineCount = goals.lazy.compactMap(\.deadline).filter {
            calendar.isDate($0, inSameDayAs: date)
        }.count

        return Button {
            onSelectDate(date)
        } label: {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(AppColors.accentBlueDepth)
                        .offset(y: 3)

                    Circle()
                        .fill(AppColors.accentBlue.gradient)
                }

                VStack(spacing: 2) {
                    Text(
                        date.formatted(
                            .dateTime
                                .day()
                                .locale(languageManager.locale)
                        )
                    )
                    .font(AppFonts.subheadlineBlack)

                    if deadlineCount > 0 {
                        Circle()
                            .fill(isSelected ? AppColors.onAccent : AppColors.accentBlue)
                            .frame(width: 4, height: 4)
                    }
                }
            }
            .foregroundStyle(isSelected ? AppColors.onAccent : AppColors.textPrimary)
            .frame(width: 34, height: 34)
            .overlay {
                if isToday, !isSelected {
                    Circle()
                        .stroke(AppColors.accentBlue.opacity(0.7), lineWidth: 1.5)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            date.formatted(
                Date.FormatStyle(
                    date: .complete,
                    time: .omitted,
                    locale: languageManager.locale
                )
            )
        )
        .accessibilityValue(
            deadlineCount > 0 ? L10n.CalendarScreen.hasDeadline : ""
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func monthButton(
        icon: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(AppFonts.captionIconBlack)
                .foregroundStyle(AppColors.accentBlue)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(
            AppDepthButtonStyle(surfaceColor: AppColors.infoSurface)
        )
        .accessibilityLabel(accessibilityLabel)
    }

    private var dates: [Date?] {
        CalendarMonthGrid.dates(
            in: month,
            calendar: languageManager.calendar
        )
    }

    private var weekdaySymbols: [String] {
        CalendarMonthGrid.weekdaySymbols(calendar: languageManager.calendar)
    }

    private var dayGridTransition: AnyTransition {
        let isNext = navigationDirection == .next
        return .asymmetric(
            insertion: .move(edge: isNext ? .trailing : .leading)
                .combined(with: .opacity),
            removal: .move(edge: isNext ? .leading : .trailing)
                .combined(with: .opacity)
        )
    }

    private var monthSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 18)
            .onEnded { value in
                let horizontalDistance = value.translation.width
                let verticalDistance = value.translation.height

                guard abs(horizontalDistance) > abs(verticalDistance) * 1.2 else {
                    return
                }

                let projectedDistance = value.predictedEndTranslation.width
                let swipeDistance = abs(projectedDistance) > abs(horizontalDistance)
                    ? projectedDistance
                    : horizontalDistance

                guard abs(swipeDistance) >= 50 else {
                    return
                }

                let movesForward = layoutDirection == .leftToRight
                    ? swipeDistance < 0
                    : swipeDistance > 0

                if movesForward {
                    onNextMonth()
                } else {
                    onPreviousMonth()
                }
            }
    }
}

import Common
import SwiftUI

struct CalendarMonthView: View {
    let month: Date
    let selectedDate: Date
    let goals: [CalendarGoalUIModel]
    let activityDays: Set<CalendarDayKey>
    let navigationDirection: CalendarMonthNavigationDirection
    let onSelectDate: (Date) -> Void
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void

    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.layoutDirection) private var layoutDirection

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
                CalendarMonthHeaderView(
                    month: month,
                    locale: languageManager.locale,
                    onPreviousMonth: onPreviousMonth,
                    onNextMonth: onNextMonth
                )

                CalendarWeekdayHeaderView(symbols: weekdaySymbols)

                ZStack {
                    CalendarMonthGridView(
                        weeks: weeks,
                        selectedDate: selectedDate,
                        activityDays: activityDays,
                        deadlineCounts: deadlineCounts,
                        calendar: languageManager.calendar,
                        locale: languageManager.locale,
                        onSelectDate: onSelectDate
                    )
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

    private var weeks: [[CalendarDayCell]] {
        CalendarMonthGrid.weeks(
            in: month,
            calendar: languageManager.calendar
        )
    }

    private var weekdaySymbols: [String] {
        CalendarMonthGrid.weekdaySymbols(
            calendar: languageManager.calendar
        )
    }

    private var deadlineCounts: [CalendarDayKey: Int] {
        goals.reduce(into: [:]) { counts, goal in
            guard let deadline = goal.deadline else {
                return
            }

            let key = CalendarDayKey(
                date: deadline,
                calendar: languageManager.calendar
            )
            counts[key, default: 0] += 1
        }
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

import Foundation

enum CalendarMonthNavigationDirection: Equatable {
    case previous
    case next
}

struct CalendarGoalUIModel: Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String?
    let deadline: Date?
    let deadlineText: String

    var hasDeadline: Bool {
        deadline != nil
    }
}

struct CalendarScreenState {
    var isLoading: Bool
    var goals: [CalendarGoalUIModel]
    var selectedDate: Date
    var displayedMonth: Date
    var monthNavigationDirection: CalendarMonthNavigationDirection
    var failureMessage: String?

    static func initial(date: Date, calendar: Calendar) -> CalendarScreenState {
        CalendarScreenState(
            isLoading: false,
            goals: [],
            selectedDate: calendar.startOfDay(for: date),
            displayedMonth: CalendarMonthGrid.startOfMonth(
                containing: date,
                calendar: calendar
            ),
            monthNavigationDirection: .next,
            failureMessage: nil
        )
    }
}

enum CalendarMonthGrid {
    static func startOfMonth(containing date: Date, calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? calendar.startOfDay(for: date)
    }

    static func dates(in month: Date, calendar: Calendar) -> [Date?] {
        guard let dayRange = calendar.range(of: .day, in: .month, for: month),
              let firstDay = calendar.date(
                from: calendar.dateComponents([.year, .month], from: month)
              ) else {
            return []
        }

        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingCount = (weekday - calendar.firstWeekday + 7) % 7
        var dates = Array<Date?>(repeating: nil, count: leadingCount)
        dates.append(
            contentsOf: dayRange.compactMap { day in
                calendar.date(byAdding: .day, value: day - 1, to: firstDay)
            }
        )

        let trailingCount = (7 - dates.count % 7) % 7
        dates.append(contentsOf: repeatElement(nil, count: trailingCount))
        return dates
    }

    static func weekdaySymbols(calendar: Calendar) -> [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let startIndex = max(0, min(symbols.count - 1, calendar.firstWeekday - 1))
        return Array(symbols[startIndex...] + symbols[..<startIndex])
    }
}

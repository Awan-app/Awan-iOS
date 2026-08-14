import Common
import Domain
import Foundation

struct CalendarGoalUIModelMapper {
    let calendar: Calendar
    let locale: Locale
    let nowProvider: () -> Date

    func updating(
        calendar: Calendar,
        locale: Locale
    ) -> CalendarGoalUIModelMapper {
        CalendarGoalUIModelMapper(
            calendar: calendar,
            locale: locale,
            nowProvider: nowProvider
        )
    }

    func map(_ goals: [Goal]) -> [CalendarGoalUIModel] {
        goals.map(map)
    }

    private func map(_ goal: Goal) -> CalendarGoalUIModel {
        let trimmedDescription = goal.description?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return CalendarGoalUIModel(
            id: goal.id,
            title: goal.name,
            description: trimmedDescription?.isEmpty == true
                ? nil
                : trimmedDescription,
            deadline: goal.deadline,
            deadlineText: deadlineText(for: goal.deadline)
        )
    }

    private func deadlineText(for deadline: Date?) -> String {
        guard let deadline else {
            return L10n.CalendarScreen.noDeadline
        }

        let today = calendar.startOfDay(for: nowProvider())
        let targetDay = calendar.startOfDay(for: deadline)
        let daysRemaining = calendar.dateComponents(
            [.day],
            from: today,
            to: targetDay
        ).day

        if let daysRemaining {
            switch daysRemaining {
            case 0:
                return L10n.CalendarScreen.dueToday
            case 1:
                return L10n.CalendarScreen.oneDayLeft
            case 2..<14:
                return L10n.CalendarScreen.daysLeft(
                    daysRemaining.formatted(.number.locale(locale))
                )
            default:
                break
            }
        }

        return deadline.formatted(
            .dateTime
                .day()
                .month(.wide)
                .year()
                .locale(locale)
        )
    }
}

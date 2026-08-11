import Combine
import Common
import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class CalendarViewModel {
    private(set) var state: CalendarScreenState

    @ObservationIgnored private let fetchGoalsUseCase: any FetchGoalsUseCase
    @ObservationIgnored private let fetchActivityDaysUseCase: any FetchActivityDaysUseCase
    @ObservationIgnored private var calendar: Calendar
    @ObservationIgnored private var locale: Locale
    @ObservationIgnored private let nowProvider: () -> Date
    @ObservationIgnored private var domainGoals: [Goal] = []
    @ObservationIgnored private var loadCancellable: AnyCancellable?
    @ObservationIgnored private var activityLoadTask: Task<Void, Never>?

    public init(
        fetchGoalsUseCase: any FetchGoalsUseCase,
        fetchActivityDaysUseCase: any FetchActivityDaysUseCase,
        initialDate: Date = .now,
        calendar: Calendar = .current,
        locale: Locale = .current,
        nowProvider: @escaping () -> Date = { .now }
    ) {
        self.fetchGoalsUseCase = fetchGoalsUseCase
        self.fetchActivityDaysUseCase = fetchActivityDaysUseCase
        self.calendar = calendar
        self.locale = locale
        self.nowProvider = nowProvider
        self.state = .initial(date: initialDate, calendar: calendar)
    }

    func send(_ action: CalendarAction) {
        switch action {
        case .appeared(let calendar, let locale):
            updatePresentationContext(calendar: calendar, locale: locale)
            load()
            loadActivityDays(for: state.displayedMonth)

        case .refresh:
            load()
            loadActivityDays(for: state.displayedMonth)

        case .selectDate(let date):
            state.selectedDate = calendar.startOfDay(for: date)

        case .showPreviousMonth:
            moveMonth(by: -1)

        case .showNextMonth:
            moveMonth(by: 1)

        case .dismissError:
            state.failureMessage = nil
        }
    }

    // MARK: - Goals loading

    private func load() {
        loadCancellable?.cancel()
        state.isLoading = state.goals.isEmpty
        state.failureMessage = nil

        loadCancellable = fetchGoalsUseCase.observe()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    state.isLoading = false
                    if case .failure(let error) = completion {
                        state.failureMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] goals in
                    guard let self else { return }
                    domainGoals = goals
                    state.goals = goals.map(makeGoalUIModel)
                    state.isLoading = false
                }
            )
    }

    // MARK: - Activity days loading

    private func loadActivityDays(for month: Date) {
        activityLoadTask?.cancel()

        guard let range = activityRange(for: month) else {
            return
        }

        activityLoadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let fetched = try await fetchActivityDaysUseCase.execute(
                    from: range.start,
                    through: range.end
                )

                guard !Task.isCancelled else {
                    return
                }

                state.activityDays.formUnion(
                    fetched.map(calendarDayKey)
                )

            } catch {
                guard !Task.isCancelled,
                      !(error is CancellationError) else {
                    return
                }

                state.failureMessage = GamificationErrorMessageMapper.message(for: error)
            }
        }
    }

    // MARK: - Month navigation

    private func moveMonth(by value: Int) {
        guard let month = calendar.date(
            byAdding: .month,
            value: value,
            to: state.displayedMonth
        ) else {
            return
        }

        state.monthNavigationDirection = value < 0 ? .previous : .next
        state.displayedMonth = CalendarMonthGrid.startOfMonth(
            containing: month,
            calendar: calendar
        )

        loadActivityDays(for: state.displayedMonth)
    }

    // MARK: - Helpers

    private func activityRange(
        for month: Date
    ) -> (start: ActivityDay, end: ActivityDay)? {
        let start = CalendarMonthGrid.startOfMonth(
            containing: month,
            calendar: calendar
        )

        guard let dayRange = calendar.range(of: .day, in: .month, for: start),
              let end = calendar.date(
                  byAdding: .day,
                  value: dayRange.count - 1,
                  to: start
              )
        else {
            return nil
        }

        return (activityDay(from: start), activityDay(from: end))
    }

    private func activityDay(from date: Date) -> ActivityDay {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return ActivityDay(
            year: components.year ?? 0,
            month: components.month ?? 0,
            day: components.day ?? 0
        )
    }

    private func calendarDayKey(from day: ActivityDay) -> CalendarDayKey {
        CalendarDayKey(year: day.year, month: day.month, day: day.day)
    }

    private func updatePresentationContext(
        calendar: Calendar,
        locale: Locale
    ) {
        self.calendar = calendar
        self.locale = locale
        state.selectedDate = calendar.startOfDay(for: state.selectedDate)
        state.displayedMonth = CalendarMonthGrid.startOfMonth(
            containing: state.displayedMonth,
            calendar: calendar
        )
        state.goals = domainGoals.map(makeGoalUIModel)
    }

    private func makeGoalUIModel(_ goal: Goal) -> CalendarGoalUIModel {
        let trimmedDescription = goal.description?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return CalendarGoalUIModel(
            id: goal.id,
            title: goal.name,
            description: trimmedDescription?.isEmpty == true
                ? nil
                : trimmedDescription,
            deadline: goal.deadline,
            deadlineText: makeDeadlineText(goal.deadline)
        )
    }

    private func makeDeadlineText(_ deadline: Date?) -> String {
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

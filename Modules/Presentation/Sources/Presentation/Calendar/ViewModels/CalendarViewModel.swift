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
    @ObservationIgnored private var activityDayMapper: CalendarActivityDayMapper
    @ObservationIgnored private var goalUIModelMapper: CalendarGoalUIModelMapper
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
        self.activityDayMapper = CalendarActivityDayMapper(calendar: calendar)
        self.goalUIModelMapper = CalendarGoalUIModelMapper(
            calendar: calendar,
            locale: locale,
            nowProvider: nowProvider
        )
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
                    state.goals = goalUIModelMapper.map(goals)
                    state.isLoading = false
                }
            )
    }

    // MARK: - Activity days loading

    private func loadActivityDays(for month: Date) {
        activityLoadTask?.cancel()

        guard let range = activityDayMapper.activityRange(for: month) else {
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
                    fetched.map(activityDayMapper.calendarDayKey)
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

    private func updatePresentationContext(
        calendar: Calendar,
        locale: Locale
    ) {
        self.calendar = calendar
        activityDayMapper = activityDayMapper.updating(calendar: calendar)
        goalUIModelMapper = goalUIModelMapper.updating(
            calendar: calendar,
            locale: locale
        )
        state.selectedDate = calendar.startOfDay(for: state.selectedDate)
        state.displayedMonth = CalendarMonthGrid.startOfMonth(
            containing: state.displayedMonth,
            calendar: calendar
        )
        state.goals = goalUIModelMapper.map(domainGoals)
    }
}

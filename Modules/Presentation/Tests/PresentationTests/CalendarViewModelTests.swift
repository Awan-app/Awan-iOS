import Combine
import Common
import Domain
import Foundation
import XCTest
@testable import Presentation

@MainActor
final class CalendarViewModelTests: XCTestCase {
    func testLoadKeepsAllGoalsIncludingMissingDeadline() async {
        let goals = [
            goal(name: "Due", deadline: date(day: 20)),
            goal(name: "Flexible", deadline: nil),
        ]
        let viewModel = makeViewModel(values: [goals])

        appear(viewModel)
        await waitUntil { viewModel.state.goals.count == 2 }

        XCTAssertEqual(viewModel.state.goals.map(\.title), ["Due", "Flexible"])
        XCTAssertFalse(viewModel.state.isLoading)
    }

    func testSelectingDateDoesNotFilterGoals() async {
        let goals = [goal(name: "Due", deadline: date(day: 20))]
        let viewModel = makeViewModel(values: [goals])
        appear(viewModel)
        await waitUntil { viewModel.state.goals.count == 1 }

        viewModel.send(.selectDate(date(day: 22)))

        XCTAssertTrue(
            calendar.isDate(viewModel.state.selectedDate, inSameDayAs: date(day: 22))
        )
        XCTAssertEqual(viewModel.state.goals.count, 1)
    }

    func testGoalItemsContainDisplayReadyDeadlineText() async {
        UserDefaults.standard.set("en", forKey: "app_language")
        let goals = [
            goal(name: "Today", deadline: date(day: 15)),
            goal(name: "Tomorrow", deadline: date(day: 16)),
            goal(name: "Soon", deadline: date(day: 28)),
            goal(name: "Later", deadline: date(day: 29)),
            goal(name: "Flexible", deadline: nil),
        ]
        let viewModel = makeViewModel(values: [goals])

        appear(viewModel)
        await waitUntil { viewModel.state.goals.count == 5 }

        XCTAssertEqual(viewModel.state.goals[0].deadlineText, "Due today")
        XCTAssertEqual(viewModel.state.goals[1].deadlineText, "1 day left")
        XCTAssertEqual(viewModel.state.goals[2].deadlineText, "13 days left")
        XCTAssertEqual(viewModel.state.goals[3].deadlineText, "July 29, 2026")
        XCTAssertEqual(viewModel.state.goals[4].deadlineText, "No deadline")
    }

    func testMonthNavigationMovesOneMonthAtATime() {
        let viewModel = makeViewModel(values: [])

        viewModel.send(.showNextMonth)
        XCTAssertEqual(
            calendar.component(.month, from: viewModel.state.displayedMonth),
            8
        )
        XCTAssertEqual(viewModel.state.monthNavigationDirection, .next)

        viewModel.send(.showPreviousMonth)
        XCTAssertEqual(
            calendar.component(.month, from: viewModel.state.displayedMonth),
            7
        )
        XCTAssertEqual(viewModel.state.monthNavigationDirection, .previous)
    }

    func testMonthGridUsesLeadingBlanksAndFullWeeks() {
        var sundayCalendar = calendar
        sundayCalendar.firstWeekday = 1

        let dates = CalendarMonthGrid.dates(
            in: date(year: 2026, month: 8, day: 1),
            calendar: sundayCalendar
        )

        XCTAssertEqual(dates.count % 7, 0)
        XCTAssertEqual(dates.prefix { $0 == nil }.count, 6)
        XCTAssertEqual(dates.compactMap { $0 }.count, 31)
    }

    func testFailureIsRetryableAndDismissible() async {
        let viewModel = CalendarViewModel(
            fetchGoalsUseCase: CalendarGoalsUseCaseStub(error: CalendarTestError.failed),
            initialDate: date(),
            calendar: calendar
        )

        appear(viewModel)
        await waitUntil { viewModel.state.failureMessage != nil }
        XCTAssertFalse(viewModel.state.isLoading)

        viewModel.send(.dismissError)
        XCTAssertNil(viewModel.state.failureMessage)
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }

    private func makeViewModel(values: [[Goal]]) -> CalendarViewModel {
        let currentDate = date()
        return CalendarViewModel(
            fetchGoalsUseCase: CalendarGoalsUseCaseStub(values: values),
            initialDate: currentDate,
            calendar: calendar,
            locale: Locale(identifier: "en"),
            nowProvider: { currentDate }
        )
    }

    private func appear(_ viewModel: CalendarViewModel) {
        viewModel.send(
            .appeared(
                calendar: calendar,
                locale: Locale(identifier: "en")
            )
        )
    }

    private func goal(name: String, deadline: Date?) -> Goal {
        Goal(
            id: UUID(),
            name: name,
            deadline: deadline,
            createdAt: date()
        )
    }

    private func date(
        year: Int = 2026,
        month: Int = 7,
        day: Int = 15
    ) -> Date {
        calendar.date(
            from: DateComponents(year: year, month: month, day: day)
        ) ?? .distantPast
    }

    private func waitUntil(_ condition: @escaping @MainActor () -> Bool) async {
        for _ in 0..<100 {
            if condition() { return }
            try? await Task.sleep(for: .milliseconds(10))
        }
    }
}

private final class CalendarGoalsUseCaseStub:
    FetchGoalsUseCase,
    @unchecked Sendable {
    private let values: [[Goal]]
    private let error: (any Error)?

    init(values: [[Goal]] = [], error: (any Error)? = nil) {
        self.values = values
        self.error = error
    }

    func execute() async throws -> [Goal] {
        if let error {
            throw error
        }
        return values.last ?? []
    }

    func observe() -> AnyPublisher<[Goal], Error> {
        if let error {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return values.publisher
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

private enum CalendarTestError: Error {
    case failed
}

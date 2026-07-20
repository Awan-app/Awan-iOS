import Domain
import Foundation
import XCTest
@testable import Presentation

final class OnboardingDraftTests: XCTestCase {
    func testDraftBuildsDomainRequestWithoutSchedulingType() throws {
        let calendar = makeCalendar()
        let draft = OnboardingDraft(
            firstName: "Awan",
            lastName: "User",
            birthDate: try XCTUnwrap(
                calendar.date(from: DateComponents(year: 2000, month: 1, day: 2))
            ),
            timezone: "Africa/Cairo",
            preferredSessionDuration: 30,
            bufferBetweenSessions: 10,
            wakeupTime: try XCTUnwrap(
                calendar.date(from: DateComponents(year: 2000, month: 1, day: 1, hour: 7, minute: 30))
            ),
            sleepTime: try XCTUnwrap(
                calendar.date(from: DateComponents(year: 2000, month: 1, day: 1, hour: 23, minute: 0))
            )
        )

        let request = try draft.makeRequest(calendar: calendar)

        XCTAssertEqual(request.firstName, "Awan")
        XCTAssertEqual(request.birthDate, try BirthDate(year: 2000, month: 1, day: 2))
        XCTAssertEqual(request.timezone, "Africa/Cairo")
        XCTAssertEqual(request.preferredSessionDuration, 30)
        XCTAssertEqual(request.bufferBetweenSessions, 10)
        XCTAssertEqual(request.wakeupTime, try LocalTime(hour: 7, minute: 30))
        XCTAssertEqual(request.sleepTime, try LocalTime(hour: 23, minute: 0))
    }

    func testDraftUsesDomainValidation() throws {
        let calendar = makeCalendar()
        let date = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2000, month: 1, day: 2, hour: 7))
        )
        let draft = OnboardingDraft(
            firstName: "Awan",
            lastName: "User",
            birthDate: date,
            timezone: "Invalid/Timezone",
            preferredSessionDuration: 30,
            bufferBetweenSessions: 10,
            wakeupTime: date,
            sleepTime: date
        )

        XCTAssertThrowsError(try draft.makeRequest(calendar: calendar)) { error in
            XCTAssertEqual(
                error as? OnboardingInputError,
                .invalidTimezone("Invalid/Timezone")
            )
        }
    }

    private func makeCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Africa/Cairo") ?? .current
        return calendar
    }
}

import Foundation
import XCTest
@testable import Domain

final class CompleteOnboardingUseCaseTests: XCTestCase {
    func testRequestRejectsBackendInvalidInput() throws {
        let birthDate = try BirthDate(year: 2000, month: 1, day: 1)
        let wakeupTime = try LocalTime(hour: 7, minute: 30)
        let sleepTime = try LocalTime(hour: 23, minute: 0)

        XCTAssertThrowsError(
            try CompleteOnboardingRequest(
                firstName: " ",
                lastName: "User",
                birthDate: birthDate,
                timezone: "Africa/Cairo",
                preferredSessionDuration: 30,
                bufferBetweenSessions: 10,
                wakeupTime: wakeupTime,
                sleepTime: sleepTime
            )
        ) { error in
            XCTAssertEqual(error as? OnboardingInputError, .blankFirstName)
        }

        XCTAssertThrowsError(
            try CompleteOnboardingRequest(
                firstName: "Awan",
                lastName: "User",
                birthDate: birthDate,
                timezone: "Invalid/Timezone",
                preferredSessionDuration: 30,
                bufferBetweenSessions: 10,
                wakeupTime: wakeupTime,
                sleepTime: sleepTime
            )
        ) { error in
            XCTAssertEqual(
                error as? OnboardingInputError,
                .invalidTimezone("Invalid/Timezone")
            )
        }

        XCTAssertThrowsError(
            try CompleteOnboardingRequest(
                firstName: "Awan",
                lastName: "User",
                birthDate: birthDate,
                timezone: "Africa/Cairo",
                preferredSessionDuration: -1,
                bufferBetweenSessions: 10,
                wakeupTime: wakeupTime,
                sleepTime: sleepTime
            )
        ) { error in
            XCTAssertEqual(
                error as? OnboardingInputError,
                .negativePreferredSessionDuration(-1)
            )
        }
    }

    func testBirthDateRejectsInvalidCalendarDate() {
        XCTAssertThrowsError(try BirthDate(year: 2001, month: 2, day: 29)) { error in
            XCTAssertEqual(error as? OnboardingInputError, .invalidBirthDate)
        }
    }

    func testUseCaseForwardsRequestAndReturnsProfile() async throws {
        let request = try makeRequest()
        let expectedProfile = try makeProfile()
        let repository = OnboardingRepositorySpy(result: .success(expectedProfile))
        let useCase = CompleteOnboardingUseCaseImpl(repository: repository)

        let profile = try await useCase.execute(request)

        XCTAssertEqual(profile, expectedProfile)
        let receivedRequest = await repository.receivedRequest
        XCTAssertEqual(receivedRequest, request)
    }

    func testUseCasePropagatesRepositoryError() async throws {
        let repository = OnboardingRepositorySpy(
            result: .failure(OnboardingError.alreadyCompleted)
        )
        let useCase = CompleteOnboardingUseCaseImpl(repository: repository)

        do {
            _ = try await useCase.execute(makeRequest())
            XCTFail("Expected onboarding to fail")
        } catch {
            XCTAssertEqual(error as? OnboardingError, .alreadyCompleted)
        }
    }

    private func makeRequest() throws -> CompleteOnboardingRequest {
        try CompleteOnboardingRequest(
            firstName: "Awan",
            lastName: "User",
            birthDate: BirthDate(year: 2000, month: 1, day: 2),
            timezone: "Africa/Cairo",
            preferredSessionDuration: 30,
            bufferBetweenSessions: 10,
            wakeupTime: LocalTime(hour: 7, minute: 30),
            sleepTime: LocalTime(hour: 23, minute: 0)
        )
    }

    private func makeProfile() throws -> UserProfile {
        UserProfile(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)),
            email: "user@example.com",
            firstName: "Awan",
            lastName: "User",
            birthDate: try BirthDate(year: 2000, month: 1, day: 2),
            points: 0,
            streak: 0,
            maxStreak: 0,
            preferences: UserPreferences(
                timezone: "Africa/Cairo",
                preferredSessionDuration: 30,
                bufferBetweenSessions: 10,
                wakeupTime: try LocalTime(hour: 7, minute: 30),
                sleepTime: try LocalTime(hour: 23, minute: 0)
            )
        )
    }
}

private actor OnboardingRepositorySpy: OnboardingRepositoryProtocol {
    private(set) var receivedRequest: CompleteOnboardingRequest?
    private let result: Result<UserProfile, any Error & Sendable>

    init(result: Result<UserProfile, any Error & Sendable>) {
        self.result = result
    }

    func completeOnboarding(_ request: CompleteOnboardingRequest) async throws -> UserProfile {
        receivedRequest = request
        return try result.get()
    }
}

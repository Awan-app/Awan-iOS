import AwaNetwork
import Domain
import Foundation
import XCTest
@testable import Data

final class OnboardingRepositoryTests: XCTestCase {
    func testRepositoryMapsRequestAndResponse() async throws {
        let response = makeResponse()
        let dataSource = OnboardingDataSourceSpy(result: .success(response))
        let repository = OnboardingRepository(remoteDataSource: dataSource)

        let profile = try await repository.completeOnboarding(makeRequest())

        XCTAssertEqual(profile.id, response.id)
        XCTAssertEqual(profile.birthDate, try BirthDate(year: 2000, month: 1, day: 2))
        XCTAssertEqual(profile.preferences.wakeupTime, try LocalTime(hour: 7, minute: 30))
        XCTAssertEqual(profile.preferences.sleepTime, try LocalTime(hour: 23, minute: 0))

        let receivedRequest = await dataSource.receivedRequest
        let request = try XCTUnwrap(receivedRequest)
        XCTAssertEqual(request.birthDate, "2000-01-02")
        XCTAssertEqual(request.wakeupTime, "07:30:00")
        XCTAssertEqual(request.sleepTime, "23:00:00")
    }

    func testRepositoryMapsValidationErrors() async throws {
        let dataSource = OnboardingDataSourceSpy(
            result: .failure(
                NetworkError.httpError(
                    statusCode: 422,
                    apiError: try makeAPIError(
                        code: "VALIDATION_ERROR",
                        info: [
                            "errors": [
                                ["field": "firstName", "message": "First name is required"]
                            ]
                        ]
                    )
                )
            )
        )
        let repository = OnboardingRepository(remoteDataSource: dataSource)

        await assertOnboardingError(
            .validationFailed([
                OnboardingFieldValidationError(
                    field: "firstName",
                    message: "First name is required"
                )
            ]),
            from: repository
        )
    }

    func testRepositoryMapsInvalidTimezone() async throws {
        let repository = OnboardingRepository(
            remoteDataSource: OnboardingDataSourceSpy(
                result: .failure(
                    NetworkError.httpError(
                        statusCode: 400,
                        apiError: try makeAPIError(code: "INVALID_TIMEZONE")
                    )
                )
            )
        )

        await assertOnboardingError(.invalidTimezone, from: repository)
    }

    func testRepositoryMapsAlreadyCompleted() async throws {
        let repository = OnboardingRepository(
            remoteDataSource: OnboardingDataSourceSpy(
                result: .failure(
                    NetworkError.httpError(
                        statusCode: 409,
                        apiError: try makeAPIError(code: "ONBOARDING_ALREADY_COMPLETED")
                    )
                )
            )
        )

        await assertOnboardingError(.alreadyCompleted, from: repository)
    }

    func testRepositoryMapsTransportAndMalformedResponseFailures() async throws {
        let transportRepository = OnboardingRepository(
            remoteDataSource: OnboardingDataSourceSpy(
                result: .failure(NetworkError.underlying(TestFailure()))
            )
        )
        await assertOnboardingError(.networkFailure, from: transportRepository)

        let malformedResponse = OnboardingResponseDTO(
            id: UUID(),
            email: "user@example.com",
            firstName: "Awan",
            lastName: "User",
            birthDate: "not-a-date",
            points: 0,
            streak: 0,
            maxStreak: 0,
            preferences: makePreferences()
        )
        let malformedRepository = OnboardingRepository(
            remoteDataSource: OnboardingDataSourceSpy(result: .success(malformedResponse))
        )
        await assertOnboardingError(.invalidResponse, from: malformedRepository)
    }

    private func assertOnboardingError(
        _ expectedError: OnboardingError,
        from repository: OnboardingRepository,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            _ = try await repository.completeOnboarding(try makeRequest())
            XCTFail("Expected onboarding to fail", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? OnboardingError, expectedError, file: file, line: line)
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

    private func makeResponse() -> OnboardingResponseDTO {
        OnboardingResponseDTO(
            id: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)),
            email: "user@example.com",
            firstName: "Awan",
            lastName: "User",
            birthDate: "2000-01-02",
            points: 0,
            streak: 0,
            maxStreak: 0,
            preferences: makePreferences()
        )
    }

    private func makePreferences() -> OnboardingPreferencesResponseDTO {
        OnboardingPreferencesResponseDTO(
            timezone: "Africa/Cairo",
            preferredSessionDuration: 30,
            bufferBetweenSessions: 10,
            wakeupTime: "07:30:00",
            sleepTime: "23:00:00"
        )
    }

    private func makeAPIError(
        code: String,
        info: [String: Any] = [:]
    ) throws -> APIErrorResponse {
        let data = try JSONSerialization.data(withJSONObject: [
            "message": "Request failed",
            "statusCode": 400,
            "errorCode": code,
            "info": info,
            "timestamp": "2026-07-19T12:00:00",
        ])
        return try JSONDecoder().decode(APIErrorResponse.self, from: data)
    }
}

private actor OnboardingDataSourceSpy: OnboardingDataSourceProtocol {
    private(set) var receivedRequest: OnboardingRequestDTO?
    private let result: Result<OnboardingResponseDTO, any Error & Sendable>

    init(result: Result<OnboardingResponseDTO, any Error & Sendable>) {
        self.result = result
    }

    func completeOnboarding(
        _ request: OnboardingRequestDTO
    ) async throws -> OnboardingResponseDTO {
        receivedRequest = request
        return try result.get()
    }
}

private struct TestFailure: Error, Sendable {}

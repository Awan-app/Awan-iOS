import Foundation
import XCTest
import AwaNetwork
@testable import Data

final class OnboardingEndpointTests: XCTestCase {
    func testCompleteEndpointUsesAuthenticatedOnboardingRoute() throws {
        let endpoint = OnboardingEndpoint.complete(makeRequest())

        XCTAssertEqual(endpoint.fullURL?.absoluteString, "http://localhost:8080/api/v1/onboarding")
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertTrue(endpoint.requiresAuthentication)
        XCTAssertNil(endpoint.queryParameters)
    }

    func testRequestEncodingMatchesBackendContractWithoutSchedulingType() throws {
        let endpoint = OnboardingEndpoint.complete(makeRequest())
        let request = try XCTUnwrap(endpoint.body as? OnboardingRequestDTO)
        let data = try JSONEncoder().encode(request)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        XCTAssertEqual(object["firstName"] as? String, "Awan")
        XCTAssertEqual(object["lastName"] as? String, "User")
        XCTAssertEqual(object["birthDate"] as? String, "2000-01-02")
        XCTAssertEqual(object["timezone"] as? String, "Africa/Cairo")
        XCTAssertEqual(object["preferredSessionDuration"] as? Int, 30)
        XCTAssertEqual(object["bufferBetweenSessions"] as? Int, 10)
        XCTAssertEqual(object["wakeupTime"] as? String, "07:30:00")
        XCTAssertEqual(object["sleepTime"] as? String, "23:00:00")
        XCTAssertNil(object["schedulingType"])
    }

    func testResponseIgnoresSchedulingTypeWhenBackendIncludesIt() throws {
        let response = try JSONDecoder().decode(
            OnboardingResponseDTO.self,
            from: responseData(includingSchedulingType: true)
        )

        XCTAssertEqual(response.preferences.timezone, "Africa/Cairo")
        XCTAssertEqual(response.preferences.wakeupTime, "07:30:00")
    }

    func testResponseDecodesWhenSchedulingTypeIsAbsent() throws {
        let response = try JSONDecoder().decode(
            OnboardingResponseDTO.self,
            from: responseData(includingSchedulingType: false)
        )

        XCTAssertEqual(response.email, "user@example.com")
        XCTAssertEqual(response.preferences.sleepTime, "23:00:00")
    }

    private func makeRequest() -> OnboardingRequestDTO {
        OnboardingRequestDTO(
            firstName: "Awan",
            lastName: "User",
            birthDate: "2000-01-02",
            timezone: "Africa/Cairo",
            preferredSessionDuration: 30,
            bufferBetweenSessions: 10,
            wakeupTime: "07:30:00",
            sleepTime: "23:00:00"
        )
    }

    private func responseData(includingSchedulingType: Bool) throws -> Data {
        var preferences: [String: Any] = [
            "timezone": "Africa/Cairo",
            "preferredSessionDuration": 30,
            "bufferBetweenSessions": 10,
            "wakeupTime": "07:30:00",
            "sleepTime": "23:00:00",
        ]
        if includingSchedulingType {
            preferences["schedulingType"] = "BALANCED"
        }

        return try JSONSerialization.data(withJSONObject: [
            "id": "00000000-0000-0000-0000-000000000001",
            "email": "user@example.com",
            "firstName": "Awan",
            "lastName": "User",
            "birthDate": "2000-01-02",
            "points": 0,
            "streak": 0,
            "maxStreak": 0,
            "preferences": preferences,
        ])
    }
}

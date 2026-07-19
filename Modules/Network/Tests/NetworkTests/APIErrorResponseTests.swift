import Foundation
import XCTest
@testable import AwaNetwork

final class APIErrorResponseTests: XCTestCase {
    func testDecodesTypedValidationMetadata() throws {
        let error = try decodeError(
            info: [
                "errors": [
                    [
                        "field": "firstName",
                        "message": "First name is required",
                        "rejectedValue": "",
                    ]
                ]
            ]
        )

        XCTAssertEqual(
            error.info?.validationErrors,
            [
                APIFieldValidationError(
                    field: "firstName",
                    message: "First name is required"
                )
            ]
        )
    }

    func testDecodesTypedAuthenticationMetadata() throws {
        let error = try decodeError(
            info: [
                "retryAfterSeconds": 30.0,
                "remainingAttempts": 4,
            ]
        )

        XCTAssertEqual(error.info?.retryAfterSeconds, 30)
        XCTAssertEqual(error.info?.remainingAttempts, 4)
        XCTAssertEqual(error.info?.validationErrors, [])
    }

    private func decodeError(info: [String: Any]) throws -> APIErrorResponse {
        let data = try JSONSerialization.data(withJSONObject: [
            "message": "Request failed",
            "statusCode": 400,
            "errorCode": "VALIDATION_ERROR",
            "info": info,
            "timestamp": "2026-07-19T12:00:00",
        ])
        return try JSONDecoder().decode(APIErrorResponse.self, from: data)
    }
}

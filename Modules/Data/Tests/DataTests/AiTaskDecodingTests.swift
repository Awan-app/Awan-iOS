import Domain
import Foundation
import XCTest
@testable import Data

final class AiTaskDecodingTests: XCTestCase {
    func testDecodeBackendResponse() throws {
        let json = """
        {
            "task": {
                "id": "7825db7c-e322-4705-8770-74a740c9333c",
                "title": "Build login page",
                "description": "Create a login page with email and password fields",
                "estimatedDuration": 60,
                "status": "SCHEDULED",
                "mandatory": true,
                "estimatedPoints": 20,
                "allowTaskSplitting": true,
                "goalId": "25a71394-afc0-442f-a660-5fa91a363c08",
                "category": null,
                "dependsOnTaskIds": []
            },
            "sessions": []
        }
        """.data(using: .utf8)!

        do {
            let decoded = try JSONDecoder().decode(TaskWithSessionsResponseDTO.self, from: json)
            XCTAssertEqual(decoded.task.title, "Build login page")
            XCTAssertEqual(decoded.task.id, UUID(uuidString: "7825db7c-e322-4705-8770-74a740c9333c"))
            XCTAssertEqual(decoded.task.estimatedDuration, 60)
            XCTAssertEqual(decoded.task.status, "SCHEDULED")
            XCTAssertEqual(decoded.task.mandatory, true)
            XCTAssertEqual(decoded.task.estimatedPoints, 20)
            XCTAssertEqual(decoded.task.isSplittable, true)
            XCTAssertEqual(decoded.task.goalID, UUID(uuidString: "25a71394-afc0-442f-a660-5fa91a363c08"))
            XCTAssertTrue(decoded.sessions.isEmpty)
            print("✅ Decoding succeeded!")
        } catch {
            print("❌ Decoding failed: \(error)")
            XCTFail("Decoding failed with error: \(error)")
        }
    }

    func testDecodeUnpersistedAiTaskResponseWithoutId() throws {
        let json = """
        {
            "task": {
                "title": "I want to go to gym and train my shoulders",
                "description": "Go to the gym and perform a shoulder-focused workout...",
                "estimatedDuration": 45,
                "mandatory": true,
                "estimatedPoints": 30,
                "allowTaskSplitting": false,
                "goalId": null,
                "categoryId": "ce755909-449e-4624-9f89-fc26657700f0"
            },
            "sessions": []
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(CreateAiTaskResponseDTO.self, from: json)
        XCTAssertEqual(decoded.task.title, "I want to go to gym and train my shoulders")
        XCTAssertEqual(decoded.task.estimatedDuration, 45)
        XCTAssertEqual(decoded.task.mandatory, true)
        XCTAssertEqual(decoded.task.estimatedPoints, 30)
        XCTAssertEqual(decoded.task.allowTaskSplitting, false)
        XCTAssertNil(decoded.task.goalId)
        XCTAssertEqual(decoded.task.categoryId, UUID(uuidString: "ce755909-449e-4624-9f89-fc26657700f0"))
        XCTAssertTrue(decoded.sessions.isEmpty)
    }
}

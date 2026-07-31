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
            "tasks": [
                {
                    "draft": {
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
                    },
                    "aiProposedSessions": [],
                    "reason": "Scheduled according to your preferences."
                }
            ]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(CreateAiTaskResponseDTO.self, from: json)
        let firstTask = try XCTUnwrap(decoded.tasks.first)
        let payload = firstTask.draft.task
        
        XCTAssertEqual(payload.title, "I want to go to gym and train my shoulders")
        XCTAssertEqual(payload.estimatedDuration, 45)
        XCTAssertEqual(payload.mandatory, true)
        XCTAssertEqual(payload.estimatedPoints, 30)
        XCTAssertEqual(payload.allowTaskSplitting, false)
        XCTAssertNil(payload.goalId)
        XCTAssertEqual(payload.categoryId, UUID(uuidString: "ce755909-449e-4624-9f89-fc26657700f0"))
        XCTAssertTrue(firstTask.aiProposedSessions.isEmpty)
        XCTAssertEqual(firstTask.reason, "Scheduled according to your preferences.")
    }

    func testDecodeAiTaskResponseWithAiProposedSessionsWithoutIdAndTaskId() throws {
        let json = """
        {
            "sourceSummary": null,
            "tasks": [
                {
                    "draft": {
                        "task": {
                            "title": "Go to the gym",
                            "description": "Fitness session",
                            "estimatedDuration": 45,
                            "mandatory": true,
                            "estimatedPoints": 2,
                            "allowTaskSplitting": false,
                            "goalId": null,
                            "categoryId": "ce755909-449e-4624-9f89-fc26657700f0"
                        },
                        "sessions": []
                    },
                    "aiProposedSessions": [
                        {
                            "zoneId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d",
                            "start": "2026-07-31T21:30:00",
                            "end": "2026-07-31T22:15:00",
                            "status": "SCHEDULED"
                        }
                    ],
                    "reason": "Optimal evening time slot."
                }
            ],
            "timestamp": "2026-07-30T13:00:00Z"
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(CreateAiTaskResponseDTO.self, from: json)
        let firstTask = try XCTUnwrap(decoded.tasks.first)
        XCTAssertEqual(firstTask.aiProposedSessions.count, 1)

        let sessionDTO = firstTask.aiProposedSessions[0]
        XCTAssertEqual(sessionDTO.zoneId, UUID(uuidString: "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d"))
        XCTAssertEqual(sessionDTO.start, "2026-07-31T21:30:00")
        XCTAssertEqual(sessionDTO.end, "2026-07-31T22:15:00")
        XCTAssertEqual(sessionDTO.status, "SCHEDULED")

        let domainSession = try sessionDTO.toDomain(timeZoneID: "GMT")
        XCTAssertEqual(domainSession.zoneID, UUID(uuidString: "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d"))
        XCTAssertEqual(domainSession.status, "SCHEDULED")
    }

    func testDecodeMultipleAiTasksResponse() throws {
        let json = """
        {
            "tasks": [
                {
                    "draft": {
                        "task": {
                            "title": "Task 1",
                            "description": "First task",
                            "estimatedDuration": 30,
                            "mandatory": true,
                            "estimatedPoints": 10,
                            "allowTaskSplitting": false,
                            "goalId": null,
                            "categoryId": null
                        },
                        "sessions": []
                    },
                    "aiProposedSessions": [],
                    "reason": "Reason 1"
                },
                {
                    "draft": {
                        "task": {
                            "title": "Task 2",
                            "description": "Second task",
                            "estimatedDuration": 60,
                            "mandatory": false,
                            "estimatedPoints": 20,
                            "allowTaskSplitting": true,
                            "goalId": null,
                            "categoryId": null
                        },
                        "sessions": []
                    },
                    "aiProposedSessions": [],
                    "reason": "Reason 2"
                }
            ]
        }
        """.data(using: .utf8)!

        let responseDTO = try JSONDecoder().decode(CreateAiTaskResponseDTO.self, from: json)
        let domainItems = try responseDTO.toDomain(timeZoneID: "GMT")

        XCTAssertEqual(domainItems.count, 2)
        XCTAssertEqual(domainItems[0].task.title, "Task 1")
        XCTAssertEqual(domainItems[0].reason, "Reason 1")
        XCTAssertEqual(domainItems[1].task.title, "Task 2")
        XCTAssertEqual(domainItems[1].reason, "Reason 2")
    }
}

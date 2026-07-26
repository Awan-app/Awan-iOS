import AwaNetwork
import Domain
import Foundation
import XCTest
@testable import Data

final class GoalDecompositionContractTests: XCTestCase {
    func testFirstMessageEncodesNullSessionID() throws {
        let request = SendGoalDecompositionMessageRequestDTO(
            sessionID: nil,
            message: "Build a portfolio"
        )
        let object = try jsonObject(request)

        XCTAssertTrue(object["sessionId"] is NSNull)
        XCTAssertEqual(object["message"] as? String, "Build a portfolio")
    }

    func testFollowUpEncodesReturnedSessionID() throws {
        let sessionID = UUID()
        let request = SendGoalDecompositionMessageRequestDTO(
            sessionID: sessionID,
            message: "1–2 months"
        )
        let object = try jsonObject(request)

        XCTAssertEqual(object["sessionId"] as? String, sessionID.uuidString)
    }

    func testEndpointsMatchGoalCreationContract() throws {
        let sessionID = UUID()
        let goalID = UUID()

        let message = GoalDecompositionEndpoint.sendMessage(
            SendGoalDecompositionMessageRequestDTO(
                sessionID: nil,
                message: "A goal"
            )
        )
        XCTAssertEqual(message.path, "/ai/goal-decompose")
        XCTAssertEqual(message.method, .post)
        XCTAssertTrue(message.requiresAuthentication)

        let confirm = GoalDecompositionEndpoint.confirm(sessionID: sessionID)
        XCTAssertEqual(
            confirm.path,
            "/ai/goal-decompose/\(sessionID.uuidString)/confirm"
        )
        XCTAssertEqual(confirm.method, .post)
        XCTAssertNil(confirm.body)

        let schedule = GoalDecompositionEndpoint.schedule(
            ScheduleGoalRequestDTO(goalID: goalID)
        )
        XCTAssertEqual(schedule.path, "/schedule")
        XCTAssertEqual(schedule.method, .post)
        let scheduleBody = try XCTUnwrap(
            schedule.body as? ScheduleGoalRequestDTO
        )
        XCTAssertEqual(
            try jsonObject(scheduleBody)["goalId"] as? String,
            goalID.uuidString
        )
    }

    func testBlockResponseDecodesAndMapsEveryContractBlock() throws {
        let sessionID = UUID()
        let categoryID = UUID()
        let json = """
        {
          "sessionId": "\(sessionID.uuidString)",
          "blocks": [
            {"type": "text", "text": "Let’s plan it."},
            {
              "type": "question",
              "text": "How long?",
              "options": ["One month", "Three months"]
            },
            {
              "type": "proposal",
              "proposal": {
                "title": "Build a portfolio",
                "description": "Showcase selected work",
                "targetDate": "2026-09-01",
                "tasks": [{
                  "tempId": "t1",
                  "title": "Choose projects",
                  "description": "Select the strongest work",
                  "estimatedDuration": 60,
                  "estimatedPoints": 10,
                  "mandatory": true,
                  "allowTaskSplitting": false,
                  "dependsOnTempIds": [],
                  "category": {
                    "id": "\(categoryID.uuidString)",
                    "name": "Career"
                  }
                }]
              }
            }
          ],
          "hasProposal": true
        }
        """

        let dto = try JSONDecoder().decode(
            GoalDecompositionResponseDTO.self,
            from: Data(json.utf8)
        )
        let response = try dto.toDomain()

        XCTAssertEqual(response.sessionID, sessionID)
        XCTAssertEqual(response.blocks.count, 3)
        XCTAssertTrue(response.hasProposal)
        guard case .proposal(let proposal) = response.blocks[2] else {
            return XCTFail("Expected proposal block")
        }
        XCTAssertEqual(proposal.tasks.first?.category?.id, categoryID)
    }

    private func jsonObject<T: Encodable>(
        _ value: T
    ) throws -> [String: Any] {
        let data = try JSONEncoder().encode(value)
        return try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
    }
}

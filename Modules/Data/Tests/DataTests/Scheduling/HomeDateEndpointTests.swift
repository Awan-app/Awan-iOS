import AwaNetwork
import Foundation
import XCTest
@testable import Data

final class HomeDateEndpointTests: XCTestCase {
    func testTaskDateEndpointMatchesBackendContract() throws {
        let endpoint = TaskEndpoint.getTasksByDate("2026-07-22")

        XCTAssertEqual(endpoint.path, "/tasks/date/2026-07-22")
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertTrue(endpoint.requiresAuthentication)
        XCTAssertNil(endpoint.queryParameters)
    }

    func testTaskRangeEndpointUsesInclusiveDateParameters() {
        let endpoint = TaskEndpoint.getTasksByDateRange(
            startDate: "2026-07-22",
            endDate: "2026-07-23"
        )

        XCTAssertEqual(endpoint.path, "/tasks/range")
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertTrue(endpoint.requiresAuthentication)
        XCTAssertEqual(
            endpoint.queryParameters,
            ["startDate": "2026-07-22", "endDate": "2026-07-23"]
        )
    }

    func testSessionDateEndpointMatchesBackendContract() {
        let endpoint = SessionEndpoint.getSessionsByDate("2026-07-22")

        XCTAssertEqual(endpoint.path, "/sessions/date/2026-07-22")
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertTrue(endpoint.requiresAuthentication)
        XCTAssertNil(endpoint.queryParameters)
    }

    func testSessionRangeEndpointUsesInclusiveDateParameters() {
        let endpoint = SessionEndpoint.getSessionsByDateRange(
            startDate: "2026-07-20",
            endDate: "2026-07-22"
        )

        XCTAssertEqual(endpoint.path, "/sessions/range")
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertTrue(endpoint.requiresAuthentication)
        XCTAssertEqual(
            endpoint.queryParameters,
            ["startDate": "2026-07-20", "endDate": "2026-07-22"]
        )
    }

    func testTaskDateResponseDecodesNestedSessionsAndTaskID() throws {
        let response = try JSONDecoder().decode(
            [TaskWithSessionsResponseDTO].self,
            from: Data(taskResponseJSON.utf8)
        )

        XCTAssertEqual(response.count, 1)
        XCTAssertEqual(response[0].task.id, taskID)
        XCTAssertEqual(response[0].sessions[0].taskID, taskID)
        XCTAssertNil(response[0].sessions[0].zoneId)
    }

    func testDateRangeResponsesDecodeDateKeys() throws {
        let taskRange = try JSONDecoder().decode(
            [String: [TaskWithSessionsResponseDTO]].self,
            from: Data("{\"2026-07-22\":\(taskResponseJSON)}".utf8)
        )
        let sessionRange = try JSONDecoder().decode(
            [String: [SessionResponseDTO]].self,
            from: Data("{\"2026-07-22\":[\(sessionJSON)]}".utf8)
        )

        XCTAssertEqual(taskRange["2026-07-22"]?.first?.task.id, taskID)
        XCTAssertEqual(sessionRange["2026-07-22"]?.first?.taskID, taskID)
    }

    func testDateKeyUsesProfileTimezone() throws {
        let instant = try XCTUnwrap(
            ISO8601DateFormatter().date(from: "2026-07-21T22:30:00Z")
        )

        XCTAssertEqual(
            LocalDateKey.value(for: instant, timeZoneID: "Africa/Cairo"),
            "2026-07-22"
        )
        XCTAssertEqual(
            LocalDateKey.value(for: instant, timeZoneID: "America/New_York"),
            "2026-07-21"
        )
    }

    private var taskID: UUID {
        UUID(uuidString: "550e8400-e29b-41d4-a716-446655440099") ?? UUID()
    }

    private var taskResponseJSON: String {
        """
        [
          {
            "task": {
              "id": "\(taskID.uuidString)",
              "title": "Task A",
              "description": null,
              "estimatedDuration": 60,
              "status": "SCHEDULED",
              "mandatory": false,
              "estimatedPoints": 10,
              "allowTaskSplitting": false,
              "goalId": null,
              "dependsOnTaskIds": []
            },
            "sessions": [\(sessionJSON)]
          }
        ]
        """
    }

    private var sessionJSON: String {
        """
        {
          "id": "550e8400-e29b-41d4-a716-446655440001",
          "start": "2026-07-22T09:00:00",
          "end": "2026-07-22T10:00:00",
          "status": "SCHEDULED",
          "locked": false,
          "zoneId": null,
          "taskId": "\(taskID.uuidString)"
        }
        """
    }
}

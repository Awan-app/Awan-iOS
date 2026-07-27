import AwaNetwork
import Domain
import Foundation
import SwiftData
import XCTest
@testable import Data

final class GoalFeedTests: XCTestCase {
    func testListEndpointUsesExactActiveCalendarQuery() {
        let endpoint = GoalEndpoint.listGoals(
            ListGoalsParameters(
                status: "ACTIVE",
                includeInbox: false,
                expand: false,
                page: 0,
                size: 20,
                sort: "createdAt,desc"
            )
        )

        XCTAssertEqual(endpoint.path, "/goals")
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertTrue(endpoint.requiresAuthentication)
        XCTAssertEqual(
            endpoint.queryParameters,
            [
                "status": "ACTIVE",
                "includeInbox": "false",
                "expand": "false",
                "page": "0",
                "size": "20",
                "sort": "createdAt,desc",
            ]
        )
    }

    func testCollapsedResponseDecodesNullTasksAndNoDeadline() throws {
        let response = try JSONDecoder().decode(
            PagedGoalResponseDTO.self,
            from: Data(collapsedResponseJSON.utf8)
        )

        XCTAssertEqual(response.content.count, 1)
        XCTAssertNil(response.content[0].tasks)
        XCTAssertNil(response.content[0].targetDate)

        let goal = try HomeRemoteMapper.goal(response.content[0])
        XCTAssertNil(goal.deadline)
        XCTAssertEqual(goal.status, .active)
        XCTAssertEqual(
            goal.createdAt,
            ISO8601DateFormatter().date(from: "2026-07-26T15:43:48Z")
        )
    }

    func testExpandedResponseDecodesTaskCategory() throws {
        let response = try JSONDecoder().decode(
            PagedGoalResponseDTO.self,
            from: Data(expandedResponseJSON.utf8)
        )

        let task = try XCTUnwrap(response.content.first?.tasks?.first)
        XCTAssertEqual(task.category?.id, categoryID)
        XCTAssertEqual(task.category?.name, "Work")
        XCTAssertEqual(task.goalID, goalID)
    }

    func testRepositoryEmitsCacheThenReconcilesRemoteActiveGoals() async throws {
        let source = SwiftDataGoalDataSource(modelContainer: try makeContainer())
        let cachedActive = Goal(
            id: UUID(),
            name: "Cached active",
            deadline: nil,
            createdAt: Date(timeIntervalSince1970: 1)
        )
        let retainedCompleted = Goal(
            id: UUID(),
            name: "Completed",
            status: .completed,
            deadline: nil,
            createdAt: Date(timeIntervalSince1970: 2)
        )
        try await source.addGoal(cachedActive)
        try await source.addGoal(retainedCompleted)

        let remoteGoal = goalDTO(
            id: goalID,
            title: "Remote active",
            targetDate: "2026-12-31"
        )
        let repository = DefaultGoalRepository(
            localDataSource: source,
            remoteDataSource: GoalRemoteDataSourceTestStub(
                mode: .response(page(content: [remoteGoal]))
            )
        )
        var iterator = repository.observeGoals().values.makeAsyncIterator()

        let cached = try await iterator.next()
        let refreshed = try await iterator.next()

        XCTAssertEqual(cached?.map(\.id), [cachedActive.id])
        XCTAssertEqual(refreshed?.map(\.id), [goalID])

        let stored = try await source.fetchGoals()
        XCTAssertTrue(stored.contains { $0.id == retainedCompleted.id })
        XCTAssertTrue(stored.contains { $0.id == goalID })
        XCTAssertFalse(stored.contains { $0.id == cachedActive.id })
    }

    func testRemoteFailureLeavesCachedGoalAvailable() async throws {
        let source = SwiftDataGoalDataSource(modelContainer: try makeContainer())
        let cached = Goal(
            id: UUID(),
            name: "Offline goal",
            deadline: nil,
            createdAt: Date()
        )
        try await source.addGoal(cached)
        let repository = DefaultGoalRepository(
            localDataSource: source,
            remoteDataSource: GoalRemoteDataSourceTestStub(mode: .failure)
        )
        var iterator = repository.observeGoals().values.makeAsyncIterator()

        let value = try await iterator.next()
        let storedIDs = try await source.fetchGoals().map(\.id)

        XCTAssertEqual(value?.map(\.id), [cached.id])
        XCTAssertEqual(storedIDs, [cached.id])
    }

    private var goalID: UUID {
        UUID(uuidString: "914b4697-2ce8-48d0-b594-7b7b7dbfad7d") ?? UUID()
    }

    private var categoryID: UUID {
        UUID(uuidString: "702b9bf6-3b00-414f-a061-f8175fd34eb6") ?? UUID()
    }

    private func goalDTO(
        id: UUID,
        title: String,
        targetDate: String?
    ) -> GoalInfoResponseDTO {
        GoalInfoResponseDTO(
            id: id,
            title: title,
            description: nil,
            status: "ACTIVE",
            targetDate: targetDate,
            createdAt: "2026-07-26T15:43:48.199260Z",
            inbox: false,
            tasks: nil
        )
    }

    private func page(content: [GoalInfoResponseDTO]) -> PagedGoalResponseDTO {
        PagedGoalResponseDTO(
            content: content,
            totalElements: content.count,
            totalPages: 1,
            number: 0,
            size: 20,
            first: true,
            last: true
        )
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = SchedulingPersistence.schema
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    private var collapsedResponseJSON: String {
        """
        {
          "content": [{
            "id": "\(goalID.uuidString)",
            "title": "Learn Spring Boot",
            "description": "Master Spring Boot",
            "status": "ACTIVE",
            "targetDate": null,
            "createdAt": "2026-07-26T15:43:48.199260Z",
            "inbox": false,
            "tasks": null
          }],
          "totalElements": 1,
          "totalPages": 1,
          "number": 0,
          "size": 20,
          "first": true,
          "last": true
        }
        """
    }

    private var expandedResponseJSON: String {
        """
        {
          "content": [{
            "id": "\(goalID.uuidString)",
            "title": "Learn Spring Boot",
            "description": "Master Spring Boot",
            "status": "ACTIVE",
            "targetDate": "2026-12-31",
            "createdAt": "2026-07-26T15:43:48.199260Z",
            "inbox": false,
            "tasks": [{
              "id": "39c640c5-4d37-472d-8a9b-4fba0f839212",
              "title": "Study JPA basics",
              "description": "Understand ORM",
              "estimatedDuration": 60,
              "status": "SCHEDULED",
              "mandatory": true,
              "estimatedPoints": 30,
              "allowTaskSplitting": false,
              "goalId": "\(goalID.uuidString)",
              "category": {
                "id": "\(categoryID.uuidString)",
                "name": "Work"
              },
              "dependsOnTaskIds": []
            }]
          }],
          "totalElements": 1,
          "totalPages": 1,
          "number": 0,
          "size": 20,
          "first": true,
          "last": true
        }
        """
    }
}

enum GoalRemoteDataSourceTestMode: Sendable {
    case response(PagedGoalResponseDTO)
    case failure
}

struct GoalRemoteDataSourceTestStub: RemoteGoalDataSource {
    let mode: GoalRemoteDataSourceTestMode

    func createGoal(
        _ request: CreateGoalRequestDTO
    ) async throws -> GoalInfoResponseDTO {
        throw GoalRemoteDataSourceTestError.unexpectedCall
    }

    func listGoals(
        parameters: ListGoalsParameters
    ) async throws -> PagedGoalResponseDTO {
        switch mode {
        case .response(let response):
            response
        case .failure:
            throw GoalRemoteDataSourceTestError.remoteFailure
        }
    }

    func getInbox() async throws -> GoalInfoResponseDTO {
        throw GoalRemoteDataSourceTestError.unexpectedCall
    }

    func getGoal(
        goalId: UUID,
        expand: Bool
    ) async throws -> GoalInfoResponseDTO {
        throw GoalRemoteDataSourceTestError.unexpectedCall
    }

    func getGoalTasks(goalId: UUID) async throws -> [TaskInfoResponseDTO] {
        throw GoalRemoteDataSourceTestError.unexpectedCall
    }

    func bulkAddTasks(
        goalId: UUID,
        request: BulkAddTasksRequestDTO
    ) async throws -> [TaskInfoResponseDTO] {
        throw GoalRemoteDataSourceTestError.unexpectedCall
    }

    func updateGoal(
        goalId: UUID,
        request: UpdateGoalRequestDTO
    ) async throws -> GoalInfoResponseDTO {
        throw GoalRemoteDataSourceTestError.unexpectedCall
    }

    func deleteGoal(goalId: UUID) async throws {
        throw GoalRemoteDataSourceTestError.unexpectedCall
    }
}

enum GoalRemoteDataSourceTestError: Error {
    case remoteFailure
    case unexpectedCall
}

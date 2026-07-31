import Combine
import Foundation
import XCTest
@testable import Domain

final class FetchGoalsUseCaseTests: XCTestCase {
    func testExecuteReturnsNewestTwentyActiveGoals() async throws {
        let active = (0..<22).map { index in
            Goal(
                id: UUID(),
                name: "Goal \(index)",
                deadline: index == 0 ? nil : Date(timeIntervalSince1970: 100),
                createdAt: Date(timeIntervalSince1970: TimeInterval(index))
            )
        }
        let completed = Goal(
            id: UUID(),
            name: "Completed",
            status: .completed,
            deadline: nil,
            createdAt: Date(timeIntervalSince1970: 10_000)
        )
        let useCase = DefaultFetchGoalsUseCase(
            repository: GoalRepositoryStub(goals: active + [completed])
        )

        let goals = try await useCase.execute()

        XCTAssertEqual(goals.count, 20)
        XCTAssertTrue(goals.allSatisfy { $0.status == .active })
        XCTAssertEqual(goals.first?.name, "Goal 21")
        XCTAssertEqual(goals.last?.name, "Goal 2")
    }
}

private struct GoalRepositoryStub: GoalRepository {
    let goals: [Goal]

    func fetchGoals() async throws -> [Goal] {
        goals
    }

    func addGoal(_ goal: Goal) async throws {}
    func updateGoal(_ goal: Goal) async throws {}
    func deleteGoal(id: UUID) async throws {}
    func deleteAllGoals() async throws {}
}

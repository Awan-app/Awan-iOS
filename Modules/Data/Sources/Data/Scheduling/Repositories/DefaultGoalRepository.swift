import Combine
import Domain
import Foundation

public struct DefaultGoalRepository: GoalRepository {
    private let localDataSource: any LocalGoalDataSource
    private let remoteDataSource: any RemoteGoalDataSource

    public init(
        localDataSource: any LocalGoalDataSource,
        remoteDataSource: any RemoteGoalDataSource
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    public func fetchGoals() async throws -> [Goal] {
        try await localDataSource.fetchGoals()
    }

    public func fetchGoalTasks(goalID: UUID) async throws -> [AwanTask] {
        let dtos = try await remoteDataSource.getGoalTasks(goalId: goalID)
        return try dtos.map { try HomeRemoteMapper.task($0, defaultDuration: 30) }
    }

    public func observeGoals() -> AnyPublisher<[Goal], Error> {
        let cached = localDataSource.observeGoals()
            .map(Self.activeGoalPage)
            .catch { _ in Empty<[Goal], Error>() }
            .eraseToAnyPublisher()
        let remote = AsyncValuePublisher.make { try await loadRemoteGoals() }
            .catch { _ in Empty<[Goal], Error>() }
            .eraseToAnyPublisher()

        return cached
            .merge(with: remote)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private func loadRemoteGoals() async throws -> [Goal] {
        let response = try await remoteDataSource.listGoals(
            parameters: ListGoalsParameters(
                status: "ACTIVE",
                includeInbox: false,
                expand: false,
                page: 0,
                size: 20,
                sort: "createdAt,desc"
            )
        )
        let goals = try response.content.map(HomeRemoteMapper.goal)
        let page = Self.activeGoalPage(goals)
        try await localDataSource.replaceActiveGoals(page)
        return page
    }

    private static func activeGoalPage(_ goals: [Goal]) -> [Goal] {
        goals
            .filter { $0.status == .active }
            .sorted {
                if $0.createdAt != $1.createdAt {
                    return $0.createdAt > $1.createdAt
                }
                return $0.id.uuidString < $1.id.uuidString
            }
            .prefix(20)
            .map { $0 }
    }

    public func addGoal(_ goal: Goal) async throws {
        try await localDataSource.addGoal(goal)
    }
    public func updateGoal(_ goal: Goal) async throws {
        try await localDataSource.updateGoal(goal)
    }
    public func deleteGoal(id: UUID) async throws {
        try await localDataSource.deleteGoal(id: id)
    }
    public func deleteAllGoals() async throws {
        try await localDataSource.deleteAllGoals()
    }
}

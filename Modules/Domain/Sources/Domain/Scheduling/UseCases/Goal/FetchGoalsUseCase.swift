import Combine

public protocol FetchGoalsUseCase: Sendable {
    func execute() async throws -> [Goal]
    func observe() -> AnyPublisher<[Goal], Error>
}

public extension FetchGoalsUseCase {
    func observe() -> AnyPublisher<[Goal], Error> {
        AsyncValuePublisher.make { try await execute() }
    }
}

public struct DefaultFetchGoalsUseCase: FetchGoalsUseCase {
    private let repository: any GoalRepository

    public init(repository: any GoalRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Goal] {
        try await repository.fetchGoals()
            .filter { $0.status == .active }
            .sorted(by: Self.goalOrder)
            .prefix(20)
            .map { $0 }
    }

    public func observe() -> AnyPublisher<[Goal], Error> {
        repository.observeGoals()
    }

    private static func goalOrder(_ lhs: Goal, _ rhs: Goal) -> Bool {
        if lhs.createdAt != rhs.createdAt {
            return lhs.createdAt > rhs.createdAt
        }
        return lhs.id.uuidString < rhs.id.uuidString
    }
}

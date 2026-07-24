import Combine
import Foundation

public protocol FetchTasksUseCase: Sendable {
    func execute(for date: Date) async throws -> [AwanTask]
    func observe(for date: Date) -> AnyPublisher<[AwanTask], Error>
}

public extension FetchTasksUseCase {
    func observe(for date: Date) -> AnyPublisher<[AwanTask], Error> {
        AsyncValuePublisher.make { try await execute(for: date) }
    }
}

public struct DefaultFetchTasksUseCase: FetchTasksUseCase {
    private let repository: any TaskRepository

    public init(repository: any TaskRepository) {
        self.repository = repository
    }

    public func execute(for date: Date) async throws -> [AwanTask] {
        try await repository.fetchTasks(for: date)
    }

    public func observe(for date: Date) -> AnyPublisher<[AwanTask], Error> {
        repository.observeTasks(for: date)
    }
}

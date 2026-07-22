import Combine

public protocol FetchTasksUseCase: Sendable {
    func execute() async throws -> [AwanTask]
    func observe() -> AnyPublisher<[AwanTask], Error>
}

public extension FetchTasksUseCase {
    func observe() -> AnyPublisher<[AwanTask], Error> {
        AsyncValuePublisher.make { try await execute() }
    }
}

public struct DefaultFetchTasksUseCase: FetchTasksUseCase {
    private let repository: any TaskRepository

    public init(repository: any TaskRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [AwanTask] {
        try await repository.fetchTasks()
    }

    public func observe() -> AnyPublisher<[AwanTask], Error> {
        repository.observeTasks()
    }
}

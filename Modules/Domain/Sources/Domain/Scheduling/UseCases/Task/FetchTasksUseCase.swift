public protocol FetchTasksUseCase: Sendable {
    func execute() async throws -> [AwanTask]
}

public struct DefaultFetchTasksUseCase: FetchTasksUseCase {
    private let repository: any TaskRepository

    public init(repository: any TaskRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [AwanTask] {
        try await repository.fetchTasks()
    }
}

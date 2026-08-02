public protocol AcceptProposedTasksUseCase: Sendable {
    func execute(_ drafts: [TaskWithSessionsDraft]) async throws -> [AwanTask]
}

public struct DefaultAcceptProposedTasksUseCase: AcceptProposedTasksUseCase {
    private let repository: any AiTaskRepository

    public init(repository: any AiTaskRepository) {
        self.repository = repository
    }

    public func execute(_ drafts: [TaskWithSessionsDraft]) async throws -> [AwanTask] {
        try await repository.acceptTasksWithSessions(drafts)
    }
}

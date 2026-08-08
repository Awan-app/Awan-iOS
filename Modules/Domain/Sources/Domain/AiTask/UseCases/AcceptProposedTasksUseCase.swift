public protocol AcceptProposedTasksUseCase: Sendable {
    func execute(
        _ tasks: [ProposedTask],
        destination: ProposedTaskDestination
    ) async throws -> [AwanTask]
}

public struct DefaultAcceptProposedTasksUseCase: AcceptProposedTasksUseCase {
    private let repository: any AiTaskRepository

    public init(repository: any AiTaskRepository) {
        self.repository = repository
    }

    public func execute(
        _ tasks: [ProposedTask],
        destination: ProposedTaskDestination
    ) async throws -> [AwanTask] {
        let drafts = tasks.map { task in
            var draft = task.draft
            if destination == .schedule {
                draft.sessions += task.aiProposedSessions
            }
            return draft
        }
        return try await repository.acceptTasksWithSessions(
            drafts,
            destination: destination
        )
    }
}

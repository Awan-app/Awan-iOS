import Foundation

public protocol AcceptProposedTaskUseCase: Sendable {
    func execute(_ draft: TaskWithSessionsDraft) async throws -> AwanTask
}

public struct DefaultAcceptProposedTaskUseCase: AcceptProposedTaskUseCase {
    private let repository: any AiTaskRepository

    public init(repository: any AiTaskRepository) {
        self.repository = repository
    }

    public func execute(_ draft: TaskWithSessionsDraft) async throws -> AwanTask {
        try await repository.acceptTaskWithSessions(draft)
    }
}

import Foundation
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
                if !draft.sessions.isEmpty {

                } else if !task.aiProposedSessions.isEmpty {
                    draft.sessions = task.aiProposedSessions
                } else {
                    let duration = draft.task.estimatedDuration > 0 ? draft.task.estimatedDuration : 60
                    let now = Date()
                    let sessionEnd = now.addingTimeInterval(Double(duration * 60))
                    draft.sessions = [
                        ProposedSession(
                            id: UUID(),
                            zoneId: nil,
                            start: now,
                            end: sessionEnd,
                            status: "SCHEDULED"
                        )
                    ]
                }
            }
            return draft
        }
        return try await repository.acceptTasksWithSessions(
            drafts,
            destination: destination
        )
    }
}

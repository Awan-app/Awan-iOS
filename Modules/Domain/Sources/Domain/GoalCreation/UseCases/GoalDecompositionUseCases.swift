import Foundation

public protocol SendGoalDecompositionMessageUseCase: Sendable {
    func execute(
        _ request: GoalDecompositionRequest
    ) async throws -> GoalDecompositionResponse
}

public struct DefaultSendGoalDecompositionMessageUseCase:
    SendGoalDecompositionMessageUseCase {
    private let repository: any GoalDecompositionRepository

    public init(repository: any GoalDecompositionRepository) {
        self.repository = repository
    }

    public func execute(
        _ request: GoalDecompositionRequest
    ) async throws -> GoalDecompositionResponse {
        try await repository.sendMessage(request)
    }
}

public protocol ConfirmGoalProposalUseCase: Sendable {
    func execute(sessionID: UUID) async throws -> ConfirmedGoal
}

public struct DefaultConfirmGoalProposalUseCase: ConfirmGoalProposalUseCase {
    private let repository: any GoalDecompositionRepository

    public init(repository: any GoalDecompositionRepository) {
        self.repository = repository
    }

    public func execute(sessionID: UUID) async throws -> ConfirmedGoal {
        try await repository.confirmProposal(sessionID: sessionID)
    }
}

public protocol ScheduleCreatedGoalUseCase: Sendable {
    func execute(goalID: UUID) async throws
}

public struct DefaultScheduleCreatedGoalUseCase: ScheduleCreatedGoalUseCase {
    private let repository: any GoalDecompositionRepository

    public init(repository: any GoalDecompositionRepository) {
        self.repository = repository
    }

    public func execute(goalID: UUID) async throws {
        try await repository.scheduleGoal(goalID: goalID)
    }
}

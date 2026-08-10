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

public protocol RequestGoalScheduleProposalUseCase: Sendable {
    func execute(goalID: UUID) async throws -> GoalScheduleProposal
}

public struct DefaultRequestGoalScheduleProposalUseCase:
    RequestGoalScheduleProposalUseCase {
    private let repository: any GoalDecompositionRepository

    public init(repository: any GoalDecompositionRepository) {
        self.repository = repository
    }

    public func execute(goalID: UUID) async throws -> GoalScheduleProposal {
        try await repository.requestScheduleProposal(goalID: goalID)
    }
}

public protocol ConfirmGoalScheduleUseCase: Sendable {
    func execute(
        goalID: UUID,
        sessions: [GoalScheduleConfirmationItem]
    ) async throws -> [ConfirmedGoalScheduleSession]
}

public struct DefaultConfirmGoalScheduleUseCase: ConfirmGoalScheduleUseCase {
    private let repository: any GoalDecompositionRepository

    public init(repository: any GoalDecompositionRepository) {
        self.repository = repository
    }

    public func execute(
        goalID: UUID,
        sessions: [GoalScheduleConfirmationItem]
    ) async throws -> [ConfirmedGoalScheduleSession] {
        try await repository.confirmSchedule(
            goalID: goalID,
            sessions: sessions
        )
    }
}

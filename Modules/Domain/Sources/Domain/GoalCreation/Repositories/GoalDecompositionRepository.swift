import Foundation

public protocol GoalDecompositionRepository: Sendable {
    func sendMessage(
        _ request: GoalDecompositionRequest
    ) async throws -> GoalDecompositionResponse

    func confirmProposal(sessionID: UUID) async throws -> ConfirmedGoal

    func requestScheduleProposal(goalID: UUID) async throws -> GoalScheduleProposal

    func confirmSchedule(
        goalID: UUID,
        sessions: [GoalScheduleConfirmationItem]
    ) async throws -> [ConfirmedGoalScheduleSession]
}

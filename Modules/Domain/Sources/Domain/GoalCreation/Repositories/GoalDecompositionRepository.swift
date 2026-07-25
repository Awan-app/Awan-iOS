import Foundation

public protocol GoalDecompositionRepository: Sendable {
    func sendMessage(
        _ request: GoalDecompositionRequest
    ) async throws -> GoalDecompositionResponse

    func confirmProposal(sessionID: UUID) async throws -> ConfirmedGoal

    func scheduleGoal(goalID: UUID) async throws
}

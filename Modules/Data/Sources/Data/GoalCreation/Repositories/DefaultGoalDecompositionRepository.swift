import Domain
import Foundation

public struct DefaultGoalDecompositionRepository: GoalDecompositionRepository {
    private let remoteDataSource: any RemoteGoalDecompositionDataSource

    public init(
        remoteDataSource: any RemoteGoalDecompositionDataSource
    ) {
        self.remoteDataSource = remoteDataSource
    }

    public func sendMessage(
        _ request: GoalDecompositionRequest
    ) async throws -> GoalDecompositionResponse {
        try await remoteDataSource.sendMessage(
            SendGoalDecompositionMessageRequestDTO(
                sessionID: request.sessionID,
                message: request.message
            )
        )
        .toDomain()
    }

    public func confirmProposal(
        sessionID: UUID
    ) async throws -> ConfirmedGoal {
        let response = try await remoteDataSource.confirmProposal(
            sessionID: sessionID
        )
        return ConfirmedGoal(id: response.id, title: response.title)
    }

    public func scheduleGoal(goalID: UUID) async throws {
        try await remoteDataSource.scheduleGoal(
            ScheduleGoalRequestDTO(goalID: goalID)
        )
    }
}

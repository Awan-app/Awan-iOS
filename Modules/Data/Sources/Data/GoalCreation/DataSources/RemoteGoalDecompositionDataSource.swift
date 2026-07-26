import AwaNetwork
import Foundation

public protocol RemoteGoalDecompositionDataSource: Sendable {
    func sendMessage(
        _ request: SendGoalDecompositionMessageRequestDTO
    ) async throws -> GoalDecompositionResponseDTO

    func confirmProposal(
        sessionID: UUID
    ) async throws -> ConfirmedGoalResponseDTO

    func scheduleGoal(_ request: ScheduleGoalRequestDTO) async throws
}

public final class DefaultRemoteGoalDecompositionDataSource:
    RemoteGoalDecompositionDataSource,
    Sendable {
    private let networkService: any NetworkServiceProtocol

    public init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func sendMessage(
        _ request: SendGoalDecompositionMessageRequestDTO
    ) async throws -> GoalDecompositionResponseDTO {
        try await networkService.request(
            GoalDecompositionEndpoint.sendMessage(request)
        )
    }

    public func confirmProposal(
        sessionID: UUID
    ) async throws -> ConfirmedGoalResponseDTO {
        try await networkService.request(
            GoalDecompositionEndpoint.confirm(sessionID: sessionID)
        )
    }

    public func scheduleGoal(_ request: ScheduleGoalRequestDTO) async throws {
        let _: EmptyResponse = try await networkService.request(
            GoalDecompositionEndpoint.schedule(request)
        )
    }
}

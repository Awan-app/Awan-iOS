import AwaNetwork
import Foundation

public protocol RemoteGoalDecompositionDataSource: Sendable {
    func sendMessage(
        _ request: SendGoalDecompositionMessageRequestDTO
    ) async throws -> GoalDecompositionResponseDTO

    func confirmProposal(
        sessionID: UUID
    ) async throws -> ConfirmedGoalResponseDTO

    func requestSchedule(
        _ request: ScheduleGoalRequestDTO
    ) async throws -> GoalScheduleProposalResponseDTO

    func confirmSchedule(
        _ request: ConfirmGoalScheduleRequestDTO
    ) async throws -> [ConfirmedGoalScheduleSessionResponseDTO]
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

    public func requestSchedule(
        _ request: ScheduleGoalRequestDTO
    ) async throws -> GoalScheduleProposalResponseDTO {
        try await networkService.request(
            GoalDecompositionEndpoint.requestSchedule(request)
        )
    }

    public func confirmSchedule(
        _ request: ConfirmGoalScheduleRequestDTO
    ) async throws -> [ConfirmedGoalScheduleSessionResponseDTO] {
        try await networkService.request(
            GoalDecompositionEndpoint.confirmSchedule(request)
        )
    }
}

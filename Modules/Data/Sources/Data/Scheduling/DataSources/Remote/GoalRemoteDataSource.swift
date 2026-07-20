//
//  GoalRemoteDataSource.swift
//  Data
//

import Foundation
import AwaNetwork

public protocol GoalRemoteDataSource: Sendable {
    func createGoal(_ request: CreateGoalRequestDTO) async throws -> GoalInfoResponseDTO
    func listGoals(parameters: ListGoalsParameters) async throws -> PagedGoalResponseDTO
    func getInbox() async throws -> GoalInfoResponseDTO
    func getGoal(goalId: UUID, expand: Bool) async throws -> GoalInfoResponseDTO
    func getGoalTasks(goalId: UUID) async throws -> [TaskInfoResponseDTO]
    func bulkAddTasks(goalId: UUID, request: BulkAddTasksRequestDTO) async throws -> [TaskInfoResponseDTO]
    func updateGoal(goalId: UUID, request: UpdateGoalRequestDTO) async throws -> GoalInfoResponseDTO
    func deleteGoal(goalId: UUID) async throws
}

public final class DefaultGoalRemoteDataSource: GoalRemoteDataSource {
    private let networkService: any NetworkServiceProtocol

    public init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func createGoal(_ request: CreateGoalRequestDTO) async throws -> GoalInfoResponseDTO {
        try await networkService.request(GoalEndpoint.createGoal(request))
    }

    public func listGoals(parameters: ListGoalsParameters) async throws -> PagedGoalResponseDTO {
        try await networkService.request(GoalEndpoint.listGoals(parameters))
    }

    public func getInbox() async throws -> GoalInfoResponseDTO {
        try await networkService.request(GoalEndpoint.getInbox)
    }

    public func getGoal(goalId: UUID, expand: Bool = false) async throws -> GoalInfoResponseDTO {
        try await networkService.request(GoalEndpoint.getGoal(goalId: goalId, expand: expand))
    }

    public func getGoalTasks(goalId: UUID) async throws -> [TaskInfoResponseDTO] {
        try await networkService.request(GoalEndpoint.getGoalTasks(goalId: goalId))
    }

    public func bulkAddTasks(
        goalId: UUID,
        request: BulkAddTasksRequestDTO
    ) async throws -> [TaskInfoResponseDTO] {
        try await networkService.request(GoalEndpoint.bulkAddTasks(goalId: goalId, request))
    }

    public func updateGoal(
        goalId: UUID,
        request: UpdateGoalRequestDTO
    ) async throws -> GoalInfoResponseDTO {
        try await networkService.request(GoalEndpoint.updateGoal(goalId: goalId, request))
    }

    public func deleteGoal(goalId: UUID) async throws {
        let _: EmptyResponse = try await networkService.request(GoalEndpoint.deleteGoal(goalId: goalId))
    }
}

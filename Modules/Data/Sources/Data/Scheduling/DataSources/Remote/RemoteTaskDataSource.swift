//
//  RemoteTaskDataSource.swift
//  Data
//

import Foundation
import AwaNetwork

public protocol RemoteTaskDataSource: Sendable {
    func getTasks(date: String) async throws -> [TaskWithSessionsResponseDTO]
    func getTasks(
        startDate: String,
        endDate: String
    ) async throws -> [String: [TaskWithSessionsResponseDTO]]
    func createTask(_ request: CreateTaskRequestDTO) async throws -> TaskInfoResponseDTO
    func getTask(taskID: UUID) async throws -> TaskInfoResponseDTO
    func updateTask(taskID: UUID, request: UpdateTaskRequestDTO) async throws -> TaskInfoResponseDTO
    func moveTask(taskID: UUID, request: MoveTaskRequestDTO) async throws -> TaskInfoResponseDTO
    func deleteTask(taskID: UUID, cascade: Bool) async throws
    func addDependency(taskID: UUID, request: AddDependencyRequestDTO) async throws
    func removeDependency(taskID: UUID, dependsOnTaskID: UUID) async throws
    func listDependencies(taskID: UUID) async throws -> [TaskInfoResponseDTO]
    func listDependents(taskID: UUID) async throws -> [TaskInfoResponseDTO]
}

public final class DefaultRemoteTaskDataSource: RemoteTaskDataSource {
    private let networkService: any NetworkServiceProtocol

    public init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func getTasks(date: String) async throws -> [TaskWithSessionsResponseDTO] {
        try await networkService.request(TaskEndpoint.getTasksByDate(date: date))
    }

    public func getTasks(
        startDate: String,
        endDate: String
    ) async throws -> [String: [TaskWithSessionsResponseDTO]] {
        try await networkService.request(
            TaskEndpoint.getTasksByDateRange(startDate: startDate, endDate: endDate)
        )
    }

    public func createTask(_ request: CreateTaskRequestDTO) async throws -> TaskInfoResponseDTO {
        try await networkService.request(TaskEndpoint.createTask(request))
    }

    public func getTask(taskID: UUID) async throws -> TaskInfoResponseDTO {
        try await networkService.request(TaskEndpoint.getTask(taskID: taskID))
    }



    public func updateTask(taskID: UUID, request: UpdateTaskRequestDTO) async throws -> TaskInfoResponseDTO {
        try await networkService.request(TaskEndpoint.updateTask(taskID: taskID, request))
    }

    public func moveTask(taskID: UUID, request: MoveTaskRequestDTO) async throws -> TaskInfoResponseDTO {
        try await networkService.request(TaskEndpoint.moveTask(taskID: taskID, request))
    }

    public func deleteTask(taskID: UUID, cascade: Bool) async throws {
        let _: EmptyResponse = try await networkService.request(TaskEndpoint.deleteTask(taskID: taskID, cascade: cascade))
    }

    public func addDependency(taskID: UUID, request: AddDependencyRequestDTO) async throws {
        let _: EmptyResponse = try await networkService.request(TaskEndpoint.addDependency(taskID: taskID, request))
    }

    public func removeDependency(taskID: UUID, dependsOnTaskID: UUID) async throws {
        let _: EmptyResponse = try await networkService.request(TaskEndpoint.removeDependency(taskID: taskID, dependsOnTaskID: dependsOnTaskID))
    }

    public func listDependencies(taskID: UUID) async throws -> [TaskInfoResponseDTO] {
        try await networkService.request(TaskEndpoint.listDependencies(taskID: taskID))
    }

    public func listDependents(taskID: UUID) async throws -> [TaskInfoResponseDTO] {
        try await networkService.request(TaskEndpoint.listDependents(taskID: taskID))
    }
}

//
//  RemoteSessionDataSource.swift
//  Data
//
//  Created by JETSMobileLabMini8 on 21/07/2026.
//

import Foundation
import AwaNetwork

public protocol RemoteSessionDataSourceProtocol: Sendable {
    func getSessions(date: String) async throws -> [SessionResponseDTO]
    func getSessions(
        startDate: String,
        endDate: String
    ) async throws -> [String: [SessionResponseDTO]]
    func getSession(sessionID: UUID) async throws -> SessionResponseDTO

    func updateSession(sessionID: UUID, request: UpdateSessionRequestDTO) async throws -> SessionResponseDTO
    func updateSessionStatus(sessionID: UUID, status: String) async throws -> SessionResponseDTO
    func lockSession(sessionID: UUID) async throws -> SessionResponseDTO
    func unlockSession(sessionID: UUID) async throws -> SessionResponseDTO
    func deleteSession(sessionID: UUID) async throws
    func createTaskWithSessions(request: CreateTaskWithSessionsRequestDTO) async throws -> TaskWithSessionsResponseDTO
    func getTaskSessions(taskID: UUID) async throws -> [SessionResponseDTO]
}

public final class RemoteSessionDataSource: RemoteSessionDataSourceProtocol {
    private let networkService: any NetworkServiceProtocol

    public init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func getSessions(date: String) async throws -> [SessionResponseDTO] {
        try await networkService.request(SessionEndpoint.getSessionsByDate(date: date))
    }

    public func getSessions(
        startDate: String,
        endDate: String
    ) async throws -> [String: [SessionResponseDTO]] {
        try await networkService.request(
            SessionEndpoint.getSessionsByDateRange(
                startDate: startDate,
                endDate: endDate
            )
        )
    }

    public func getSession(sessionID: UUID) async throws -> SessionResponseDTO {
        try await networkService.request(SessionEndpoint.getSession(sessionID: sessionID))
    }



    public func updateSession(sessionID: UUID, request: UpdateSessionRequestDTO) async throws -> SessionResponseDTO {
        try await networkService.request(SessionEndpoint.updateSession(sessionID: sessionID, request))
    }

    public func updateSessionStatus(sessionID: UUID, status: String) async throws -> SessionResponseDTO {
        try await networkService.request(SessionEndpoint.updateSessionStatus(sessionID: sessionID, status: status))
    }

    public func lockSession(sessionID: UUID) async throws -> SessionResponseDTO {
        try await networkService.request(SessionEndpoint.lockSession(sessionID: sessionID))
    }

    public func unlockSession(sessionID: UUID) async throws -> SessionResponseDTO {
        try await networkService.request(SessionEndpoint.unlockSession(sessionID: sessionID))
    }

    public func deleteSession(sessionID: UUID) async throws {
        let _: EmptyResponse = try await networkService.request(
            SessionEndpoint.deleteSession(sessionID: sessionID)
        )
    }

    public func createTaskWithSessions(request: CreateTaskWithSessionsRequestDTO) async throws -> TaskWithSessionsResponseDTO {
        try await networkService.request(SessionEndpoint.createTaskWithSessions(request))
    }

    public func getTaskSessions(taskID: UUID) async throws -> [SessionResponseDTO] {
        try await networkService.request(SessionEndpoint.getTaskSessions(taskID: taskID))
    }
}

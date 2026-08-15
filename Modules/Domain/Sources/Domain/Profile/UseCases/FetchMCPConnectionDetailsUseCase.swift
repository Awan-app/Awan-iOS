//
//  FetchMCPConnectionDetailsUseCase.swift
//  Domain
//

import Foundation

public protocol FetchMCPConnectionDetailsUseCase: Sendable {
    func execute() async throws -> MCPConnectionDetails
}

public struct DefaultFetchMCPConnectionDetailsUseCase: FetchMCPConnectionDetailsUseCase {
    private let repository: any UserProfileRepository

    public init(repository: any UserProfileRepository) {
        self.repository = repository
    }

    public func execute() async throws -> MCPConnectionDetails {
        try await repository.fetchMCPConnectionDetails()
    }
}

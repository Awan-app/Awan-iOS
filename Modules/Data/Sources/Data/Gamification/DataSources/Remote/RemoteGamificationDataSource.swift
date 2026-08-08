//
//  RemoteGamificationDataSource.swift
//  Data
//
//  Created by Eslam Elnady on 08/08/2026.
//
import AwaNetwork

public protocol RemoteGamificationDataSource: Sendable {
    func getProgress() async throws -> UserProgressResponseDTO
}

public final class DefaultRemoteGamificationDataSource:
    RemoteGamificationDataSource {

    private let networkService: any NetworkServiceProtocol

    public init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func getProgress() async throws -> UserProgressResponseDTO {
        try await networkService.request(
            GamificationEndpoint.getProgress
        )
    }
}

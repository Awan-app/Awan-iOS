//
//  RemoteAiTaskDataSource.swift
//  Data
//

import Foundation
import AwaNetwork

public protocol AiTaskRemoteDataSource: Sendable {
    func createAITask(_ request: CreateAITaskRequestDTO) async throws -> AITaskInfoResponseDTO
}

public final class DefaultAiTaskRemoteDataSource: AiTaskRemoteDataSource {
    private let networkService: any NetworkServiceProtocol

    public init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func createAITask(_ request: CreateAITaskRequestDTO) async throws -> AITaskInfoResponseDTO {
        try await networkService.request(AiTaskEndpoint.createAITask(request))
    }
}

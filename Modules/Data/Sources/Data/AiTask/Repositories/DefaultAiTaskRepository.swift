//
//  DefaultAiTaskRepository.swift
//  Data
//

import Domain
import Foundation

public final class DefaultAiTaskRepository: AiTaskRepository {
    private let remoteDataSource: any AiTaskRemoteDataSource

    public init(remoteDataSource: any AiTaskRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    public func createAITask(text: String) async throws -> [AITaskSheetItem] {
        let request = CreateAITaskRequestDTO(text: text)
        let response = try await remoteDataSource.createAITask(request)
        return try response.toDomain(timeZoneID: TimeZone.current.identifier)
    }
}

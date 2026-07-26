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

    public func createAITask(title: String, description: String?) async throws -> AITask {
        let request = CreateAITaskRequestDTO(title: title, description: description)
        let response = try await remoteDataSource.createAITask(request)
        return response.toDomain()
    }
}

// MARK: - Mapping

private extension TaskInfoResponseDTO {
    func toDomain() -> AITask {
        AITask(
            id: id,
            title: title,
            description: description,
            estimatedDuration: estimatedDuration ?? 0,
            status: status,
            mandatory: mandatory,
            estimatedPoints: estimatedPoints,
            isSplittable: isSplittable,
            goalID: goalID ?? UUID(),
            dependencyIDs: dependencyIDs,
            category: category?.toDomain()
        )
    }
}

private extension CategoryResponseDTO {
    func toDomain() -> TaskCategory {
        TaskCategory(id: id, name: name)
    }
}

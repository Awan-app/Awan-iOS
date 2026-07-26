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

    public func createAITask(title: String, description: String?) async throws -> AwanTask {
        let request = CreateAITaskRequestDTO(title: title, description: description)
        let response = try await remoteDataSource.createAITask(request)
        return response.toDomain()
    }
}

// MARK: - Mapping

private extension TaskInfoResponseDTO {
    func toDomain() -> AwanTask {
        AwanTask(
            id: id,
            title: title,
            description: description,
            status: mappedStatus(from: status),
            goalID: goalID,
            zoneID: nil,
            duration: try! TaskDuration(minutes: max(1, estimatedDuration ?? 60)),
            isSplittable: isSplittable,
            mandatory: mandatory,
            estimatedPoints: estimatedPoints,
            dependencyIDs: Set(dependencyIDs),
            category: category?.toDomain()
        )
    }

    private func mappedStatus(from raw: String) -> TaskStatus {
        switch raw.uppercased() {
        case "SCHEDULED", "PENDING": .pending
        case "IN_PROGRESS": .inProgress
        case "COMPLETED": .completed
        case "CANCELLED": .cancelled
        default: .pending
        }
    }
}

private extension CategoryResponseDTO {
    func toDomain() -> TaskCategory {
        TaskCategory(id: id, name: name)
    }
}

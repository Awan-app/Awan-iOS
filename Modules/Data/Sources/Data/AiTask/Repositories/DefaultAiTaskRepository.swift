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

    public func createAITask(title: String, description: String?) async throws -> AITaskSheetItem {
        let request = CreateAITaskRequestDTO(title: title, description: description)
        let response = try await remoteDataSource.createAITask(request)
        return try response.toDomain(timeZoneID: TimeZone.current.identifier)
    }
}

// MARK: - Mapping

private extension CreateAiTaskResponseDTO {
    func toDomain(timeZoneID: String) throws -> AITaskSheetItem {
        let mappedTask = AwanTask(
            id: UUID(),
            title: task.title,
            description: task.description,
            status: .pending,
            goalID: task.goalId,
            zoneID: nil,
            duration: try! TaskDuration(minutes: max(1, task.estimatedDuration ?? 60)),
            isSplittable: task.allowTaskSplitting ?? false,
            mandatory: task.mandatory ?? false,
            estimatedPoints: task.estimatedPoints ?? 0,
            dependencyIDs: [],
            category: task.categoryId.map { TaskCategory(id: $0, name: "") }
        )
        let mappedSessions = try sessions.map { try HomeRemoteMapper.session($0, timeZoneID: timeZoneID) }
        let startTime = mappedSessions.first?.timeRange.start ?? Date()
        return AITaskSheetItem(task: mappedTask, startTime: startTime, sessions: mappedSessions)
    }
}

private extension CategoryResponseDTO {
    func toDomain() -> TaskCategory {
        TaskCategory(id: id, name: name)
    }
}

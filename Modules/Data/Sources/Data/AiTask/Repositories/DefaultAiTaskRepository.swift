//
//  DefaultAiTaskRepository.swift
//  Data
//

import Domain
import Foundation

public final class DefaultAiTaskRepository: AiTaskRepository {
    private let remoteDataSource: any AiTaskRemoteDataSource
    private let localTaskDataSource: (any LocalTaskDataSource)?
    private let localSessionDataSource: (any LocalSessionDataSource)?
    private let timeZoneID: String

    public init(
        remoteDataSource: any AiTaskRemoteDataSource,
        localTaskDataSource: (any LocalTaskDataSource)? = nil,
        localSessionDataSource: (any LocalSessionDataSource)? = nil,
        timeZoneID: String = TimeZone.current.identifier
    ) {
        self.remoteDataSource = remoteDataSource
        self.localTaskDataSource = localTaskDataSource
        self.localSessionDataSource = localSessionDataSource
        self.timeZoneID = timeZoneID
    }

    public func createAITask(text: String) async throws -> [AITaskSheetItem] {
         let request = CreateAITaskRequestDTO(text: text)
        let response = try await remoteDataSource.createAITask(request)
        return try response.toDomain(timeZoneID: TimeZone.current.identifier)
    }

    public func imageToTasks(imageData: Data, mimeType: String, note: String?) async throws -> TaskProposalResponse {
        let responseDTO = try await remoteDataSource.imageToTasks(imageData: imageData, mimeType: mimeType, note: note)
        return responseDTO.toDomain()
    }

    public func acceptTaskWithSessions(_ draft: TaskWithSessionsDraft) async throws -> AwanTask {
        let requestDTO = CreateTaskWithSessionsRequestDTO(draft: draft)
        let responseDTO = try await remoteDataSource.acceptTaskWithSessions(requestDTO)
        let acceptedTask = (try? HomeRemoteMapper.task(responseDTO.task, defaultDuration: draft.task.estimatedDuration)) ?? responseDTO.task.toDomain()

        if let localTaskDataSource {
            try? await localTaskDataSource.addTask(acceptedTask)
        }
        if let localSessionDataSource {
            let acceptedSessions = responseDTO.sessions.compactMap {
                try? HomeRemoteMapper.session($0, timeZoneID: timeZoneID)
            }
            for session in acceptedSessions {
                try? await localSessionDataSource.addSession(session)
            }
        }
        return acceptedTask
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

//
//  DefaultAiTaskRepository.swift
//  Data
//

import Domain
import Foundation

public final class DefaultAiTaskRepository: AiTaskRepository {
    private let remoteDataSource: any AiTaskRemoteDataSource
    private let localTaskDataSource: any LocalTaskDataSource
    private let localSessionDataSource: any LocalSessionDataSource
    private let timeZoneID: String

    public init(
        remoteDataSource: any AiTaskRemoteDataSource,
        localTaskDataSource: any LocalTaskDataSource,
        localSessionDataSource: any LocalSessionDataSource,
        timeZoneID: String = TimeZone.current.identifier
    ) {
        self.remoteDataSource = remoteDataSource
        self.localTaskDataSource = localTaskDataSource
        self.localSessionDataSource = localSessionDataSource
        self.timeZoneID = timeZoneID
    }

    public func createAITask(text: String) async throws -> TaskProposal {
         let request = CreateAITaskRequestDTO(text: text)
        let response = try await remoteDataSource.createAITask(request)
        return response.toDomain()
    }

    public func imageToTasks(imageData: Data, mimeType: String, note: String?) async throws -> TaskProposal {
        let responseDTO = try await remoteDataSource.imageToTasks(imageData: imageData, mimeType: mimeType, note: note)
        return responseDTO.toDomain()
    }

    public func acceptTaskWithSessions(_ draft: TaskWithSessionsDraft) async throws -> AwanTask {
        let requestDTO = CreateTaskWithSessionsRequestDTO(draft: draft)
        let responseDTO = try await remoteDataSource.acceptTaskWithSessions(requestDTO)
        return try await persist(responseDTO, draft: draft)
    }

    public func acceptTasksWithSessions(
        _ drafts: [TaskWithSessionsDraft]
    ) async throws -> [AwanTask] {
        let requestDTO = BulkCreateTasksWithSessionsRequestDTO(drafts: drafts)
        let responseDTO = try await remoteDataSource.acceptTasksWithSessions(requestDTO)

        var acceptedTasks: [AwanTask] = []
        acceptedTasks.reserveCapacity(responseDTO.tasks.count)
        for (index, response) in responseDTO.tasks.enumerated() {
            let draft = drafts.indices.contains(index) ? drafts[index] : nil
            acceptedTasks.append(try await persist(response, draft: draft))
        }
        return acceptedTasks
    }

    private func persist(
        _ responseDTO: TaskWithSessionsResponseDTO,
        draft: TaskWithSessionsDraft?
    ) async throws -> AwanTask {
        let defaultDuration = draft?.task.estimatedDuration ?? 60
        var acceptedTask = (try? HomeRemoteMapper.task(
            responseDTO.task,
            defaultDuration: defaultDuration
        )) ?? responseDTO.task.toDomain()

        if let draft {
            acceptedTask = acceptedTask.applyingDraftGoalID(draft.task.goalId)
        }

        try? await localTaskDataSource.addTask(acceptedTask)
        let acceptedSessions = responseDTO.sessions.compactMap {
            try? HomeRemoteMapper.session($0, timeZoneID: timeZoneID)
        }
        for session in acceptedSessions {
            try? await localSessionDataSource.addSession(session)
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

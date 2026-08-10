//
//  DefaultAiTaskRepository.swift
//  Data
//

import Domain
import Foundation

public final class DefaultAiTaskRepository: AiTaskRepository {
    private let remoteDataSource: any AiTaskRemoteDataSource
    private let remoteGoalDataSource: any RemoteGoalDataSource
    private let localTaskDataSource: any LocalTaskDataSource
    private let localSessionDataSource: any LocalSessionDataSource
    private let timeZoneID: String

    public init(
        remoteDataSource: any AiTaskRemoteDataSource,
        remoteGoalDataSource: any RemoteGoalDataSource,
        localTaskDataSource: any LocalTaskDataSource,
        localSessionDataSource: any LocalSessionDataSource,
        timeZoneID: String = TimeZone.current.identifier
    ) {
        self.remoteDataSource = remoteDataSource
        self.remoteGoalDataSource = remoteGoalDataSource
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
        _ drafts: [TaskWithSessionsDraft],
        destination: ProposedTaskDestination
    ) async throws -> [AwanTask] {
        let preparedDrafts = try await prepare(drafts, for: destination)
        let requestDTO = BulkCreateTasksWithSessionsRequestDTO(drafts: preparedDrafts)
        let responseDTO = try await remoteDataSource.acceptTasksWithSessions(requestDTO)

        var acceptedTasks: [AwanTask] = []
        acceptedTasks.reserveCapacity(responseDTO.tasks.count)
        for (index, response) in responseDTO.tasks.enumerated() {
            let draft = preparedDrafts.indices.contains(index) ? preparedDrafts[index] : nil
            acceptedTasks.append(try await persist(response, draft: draft))
        }
        return acceptedTasks
    }

    private func prepare(
        _ drafts: [TaskWithSessionsDraft],
        for destination: ProposedTaskDestination
    ) async throws -> [TaskWithSessionsDraft] {
        switch destination {
        case .schedule:
            return drafts
        case .inbox:
            let inboxGoalID = try await remoteGoalDataSource.getInbox().id
            return drafts.map { draft in
                var inboxDraft = draft
                inboxDraft.task.goalId = inboxGoalID
                inboxDraft.sessions = []
                return inboxDraft
            }
        }
    }

    private func persist(
        _ responseDTO: TaskWithSessionsResponseDTO,
        draft: TaskWithSessionsDraft?
    ) async throws -> AwanTask {
        let defaultDuration = draft?.task.estimatedDuration ?? 60
        let acceptedTask = (try? HomeRemoteMapper.task(
            responseDTO.task,
            defaultDuration: defaultDuration
        )) ?? responseDTO.task.toDomain()

        let acceptedSessions = try responseDTO.sessions.map {
            try HomeRemoteMapper.session($0, timeZoneID: timeZoneID)
        }
        try await localTaskDataSource.upsertTasks([acceptedTask])
        try await localSessionDataSource.upsertSessions(acceptedSessions)
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
            completedAt: mappedCompletedAt,
            goalID: goalID,
            duration: try! TaskDuration(minutes: max(1, estimatedDuration ?? 60)),
            isSplittable: isSplittable,
            mandatory: mandatory,
            estimatedPoints: estimatedPoints,
            dependencyIDs: Set(dependencyIDs),
            category: category?.toDomain()
        )
    }

    private var mappedCompletedAt: Date? {
        guard let completedAt else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: completedAt)
    }

    private func mappedStatus(from raw: String) -> TaskStatus {
        switch raw.uppercased() {
        case "DRAFTED": .drafted
        case "ACTIVE", "SCHEDULED", "PENDING", "IN_PROGRESS": .active
        case "COMPLETED": .completed
        case "CANCELLED": .cancelled
        default: .drafted
        }
    }
}

private extension CategoryResponseDTO {
    func toDomain() -> TaskCategory {
        TaskCategory(id: id, name: name)
    }
}

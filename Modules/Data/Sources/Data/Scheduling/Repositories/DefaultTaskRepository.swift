import Combine
import Domain
import Foundation

public struct DefaultTaskRepository: TaskRepository {
    private let localDataSource: any LocalTaskDataSource
    private let localSessionDataSource: any LocalSessionDataSource
    private let localProfileDataSource: any LocalUserProfileDataSource
    private let remoteTaskDataSource: any RemoteTaskDataSource
    private let remoteGoalDataSource: any RemoteGoalDataSource
    private let remoteSessionDataSource: any RemoteSessionDataSourceProtocol

    public init(
        localDataSource: any LocalTaskDataSource,
        localSessionDataSource: any LocalSessionDataSource,
        localProfileDataSource: any LocalUserProfileDataSource,
        remoteTaskDataSource: any RemoteTaskDataSource,
        remoteGoalDataSource: any RemoteGoalDataSource,
        remoteSessionDataSource: any RemoteSessionDataSourceProtocol
    ) {
        self.localDataSource = localDataSource
        self.localSessionDataSource = localSessionDataSource
        self.localProfileDataSource = localProfileDataSource
        self.remoteTaskDataSource = remoteTaskDataSource
        self.remoteGoalDataSource = remoteGoalDataSource
        self.remoteSessionDataSource = remoteSessionDataSource
    }

    public func fetchTasks() async throws -> [AwanTask] {
        try await localDataSource.fetchTasks()
    }
    public func observeTasks() -> AnyPublisher<[AwanTask], Error> {
        let local = localDataSource.observeTasks()
        let remote = AsyncValuePublisher.make { try await loadRemoteTasks() }
            .catch { _ in Empty<[AwanTask], Error>() }
        return local
            .merge(with: remote)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private func loadRemoteTasks() async throws -> [AwanTask] {
        guard let profile = try await localProfileDataSource.fetchProfile() else {
            throw RemoteDomainMappingError.missingField("cachedProfile")
        }
        let cachedByID = Dictionary(
            uniqueKeysWithValues: try await fetchTasks().map { ($0.id, $0) }
        )
        var page = 0
        var remoteByID: [UUID: TaskInfoResponseDTO] = [:]
        while true {
            let response = try await remoteGoalDataSource.listGoals(
                parameters: ListGoalsParameters(
                    includeInbox: true,
                    expand: true,
                    page: page,
                    size: 100,
                    sort: "createdAt,asc"
                )
            )
            for task in response.content.flatMap(\.tasks) {
                remoteByID[task.id] = task
            }
            if response.last { break }
            page += 1
        }
        let tasks = try remoteByID.values.map { dto in
            try HomeRemoteMapper.task(
                dto,
                zoneID: cachedByID[dto.id]?.zoneID,
                defaultDuration: profile.preferences.preferredSessionDuration
            )
        }
        .sorted { $0.id.uuidString < $1.id.uuidString }
        try await localDataSource.replaceTasks(tasks)
        return tasks
    }
    public func addTask(_ task: AwanTask) async throws {
        try await localDataSource.addTask(task)
    }

    public func addManualTask(_ task: AwanTask, startsAt: Date?, durationMinutes: Int, timeZoneID: String) async throws -> (task: AwanTask, sessions: [Session]) {
        let sessionPayloads: [CreateTaskWithSessionsRequestDTO.SessionPayload]?
        if let start = startsAt {
            let end = start.addingTimeInterval(TimeInterval(durationMinutes * 60))
            sessionPayloads = [
                CreateTaskWithSessionsRequestDTO.SessionPayload(
                    zoneId: task.zoneID,
                    start: HomeRemoteMapper.formatDateTime(start, timeZoneID: timeZoneID),
                    end: HomeRemoteMapper.formatDateTime(end, timeZoneID: timeZoneID),
                    status: "SCHEDULED"
                )
            ]
        } else {
            sessionPayloads = nil
        }

        let request = CreateTaskWithSessionsRequestDTO(
            task: CreateTaskWithSessionsRequestDTO.TaskPayload(
                title: task.title,
                description: task.description,
                estimatedDuration: durationMinutes,
                mandatory: task.mandatory,
                estimatedPoints: task.estimatedPoints,
                allowTaskSplitting: task.isSplittable,
                goalId: task.goalID
            ),
            sessions: sessionPayloads
        )

        let response = try await remoteSessionDataSource.createTaskWithSessions(request: request)
        let acceptedTask = try HomeRemoteMapper.task(
            response.task,
            zoneID: task.zoneID,
            defaultDuration: durationMinutes
        )
        try await localDataSource.addTask(acceptedTask)

        let acceptedSessions = try response.sessions.map {
            try HomeRemoteMapper.session(
                $0,
                taskID: acceptedTask.id,
                timeZoneID: timeZoneID
            )
        }
        for session in acceptedSessions {
            try await localSessionDataSource.addSession(session)
        }

        return (acceptedTask, acceptedSessions)
    }
    public func updateTask(_ task: AwanTask) async throws {
        let response = try await remoteTaskDataSource.updateTask(
            taskID: task.id,
            request: UpdateTaskRequestDTO(
                title: task.title,
                description: task.description,
                estimatedDuration: task.duration.minutes,
                status: remoteStatus(task.status),
                mandatory: task.mandatory,
                estimatedPoints: task.estimatedPoints,
                isSplittable: task.isSplittable
            )
        )
        let accepted = try HomeRemoteMapper.task(
            response,
            zoneID: task.zoneID,
            defaultDuration: task.duration.minutes
        )
        try await localDataSource.updateTask(accepted)
    }
    public func deleteTask(id: UUID) async throws {
        try await remoteTaskDataSource.deleteTask(taskID: id, cascade: true)
        try await localSessionDataSource.deleteSessions(taskID: id)
        let existing = try await localDataSource.fetchTasks()
        for task in existing where task.dependencyIDs.contains(id) {
            try await localDataSource.updateTask(
                replacingDependencies(
                    of: task,
                    with: task.dependencyIDs.subtracting([id])
                )
            )
        }
        try await localDataSource.deleteTask(id: id)
    }
    public func deleteAllTasks() async throws {
        try await localDataSource.deleteAllTasks()
    }
    public func addDependency(taskID: UUID, dependsOnID: UUID) async throws {
        try await localDataSource.addDependency(taskID: taskID, dependsOnID: dependsOnID)
    }
    public func removeDependency(taskID: UUID, dependsOnID: UUID) async throws {
        try await localDataSource.removeDependency(taskID: taskID, dependsOnID: dependsOnID)
    }
    public func fetchDependencies(taskID: UUID) async throws -> [AwanTask] {
        try await localDataSource.fetchDependencies(taskID: taskID)
    }
    public func fetchDependents(taskID: UUID) async throws -> [AwanTask] {
        try await localDataSource.fetchDependents(taskID: taskID)
    }

    private func remoteStatus(_ status: TaskStatus) -> String {
        switch status {
        case .pending: "SCHEDULED"
        case .inProgress: "IN_PROGRESS"
        case .completed: "COMPLETED"
        case .cancelled: "CANCELLED"
        }
    }

    private func replacingDependencies(
        of task: AwanTask,
        with dependencyIDs: Set<UUID>
    ) -> AwanTask {
        AwanTask(
            id: task.id,
            title: task.title,
            description: task.description,
            status: task.status,
            goalID: task.goalID,
            zoneID: task.zoneID,
            duration: task.duration,
            isSplittable: task.isSplittable,
            mandatory: task.mandatory,
            estimatedPoints: task.estimatedPoints,
            dependencyIDs: dependencyIDs
        )
    }
}

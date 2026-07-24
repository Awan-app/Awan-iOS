import Combine
import Domain
import Foundation

public struct DefaultTaskRepository: TaskRepository {
    private let localDataSource: any LocalTaskDataSource
    private let localSessionDataSource: any LocalSessionDataSource
    private let localProfileDataSource: any LocalUserProfileDataSource
    private let remoteTaskDataSource: any RemoteTaskDataSource

    public init(
        localDataSource: any LocalTaskDataSource,
        localSessionDataSource: any LocalSessionDataSource,
        localProfileDataSource: any LocalUserProfileDataSource,
        remoteTaskDataSource: any RemoteTaskDataSource
    ) {
        self.localDataSource = localDataSource
        self.localSessionDataSource = localSessionDataSource
        self.localProfileDataSource = localProfileDataSource
        self.remoteTaskDataSource = remoteTaskDataSource
    }

    public func fetchTasks() async throws -> [AwanTask] {
        try await localDataSource.fetchTasks()
    }
    public func fetchTasks(for date: Date) async throws -> [AwanTask] {
        let profile = try await requireProfile()
        return try await cachedTasks(
            forDay: LocalDateKey.value(
                for: date,
                timeZoneID: profile.preferences.timezone
            ),
            timeZoneID: profile.preferences.timezone
        )
    }

    public func observeTasks(for date: Date) -> AnyPublisher<[AwanTask], Error> {
        AsyncValuePublisher.make { try await requireProfile() }
            .flatMap { profile -> AnyPublisher<[AwanTask], Error> in
                let dayKey = LocalDateKey.value(
                    for: date,
                    timeZoneID: profile.preferences.timezone
                )
                let local = localDataSource.observeTasks()
                    .combineLatest(localSessionDataSource.observeSessions())
                    .map { tasks, sessions in
                        tasksForDay(
                            tasks,
                            sessions: sessions,
                            dayKey: dayKey,
                            timeZoneID: profile.preferences.timezone
                        )
                    }
                    .eraseToAnyPublisher()
                let remote = AsyncValuePublisher.make {
                    try await loadRemoteTasks(
                        dayKey: dayKey,
                        profile: profile
                    )
                }
                .catch { _ in Empty<[AwanTask], Error>() }
                .eraseToAnyPublisher()
                return local
                    .merge(with: remote)
                    .removeDuplicates()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func loadRemoteTasks(
        dayKey: String,
        profile: UserProfile
    ) async throws -> [AwanTask] {
        let cachedByID = Dictionary(
            uniqueKeysWithValues: try await fetchTasks().map { ($0.id, $0) }
        )
        let responses = try await remoteTaskDataSource.getTasks(date: dayKey)
        let tasks = try responses.map { response in
            try HomeRemoteMapper.task(
                response.task,
                zoneID: response.sessions.compactMap(\.zoneId).first
                    ?? cachedByID[response.task.id]?.zoneID,
                defaultDuration: profile.preferences.preferredSessionDuration
            )
        }
        .sorted { $0.id.uuidString < $1.id.uuidString }
        try await localDataSource.upsertTasks(tasks)
        return tasks
    }

    private func cachedTasks(
        forDay dayKey: String,
        timeZoneID: String
    ) async throws -> [AwanTask] {
        tasksForDay(
            try await localDataSource.fetchTasks(),
            sessions: try await localSessionDataSource.fetchSessions(),
            dayKey: dayKey,
            timeZoneID: timeZoneID
        )
    }

    private func tasksForDay(
        _ tasks: [AwanTask],
        sessions: [Session],
        dayKey: String,
        timeZoneID: String
    ) -> [AwanTask] {
        let taskIDs = Set(
            sessions.lazy
                .filter {
                    LocalDateKey.value(
                        for: $0.timeRange.start,
                        timeZoneID: timeZoneID
                    ) == dayKey
                }
                .map(\.taskID)
        )
        return tasks
            .filter { taskIDs.contains($0.id) }
            .sorted { $0.id.uuidString < $1.id.uuidString }
    }

    private func requireProfile() async throws -> UserProfile {
        guard let profile = try await localProfileDataSource.fetchProfile() else {
            throw RemoteDomainMappingError.missingField("cachedProfile")
        }
        return profile
    }
    public func addTask(_ task: AwanTask) async throws {
        try await localDataSource.addTask(task)
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

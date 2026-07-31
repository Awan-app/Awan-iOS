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
        localDataSource.observeTasks()
    }
    public func fetchTasks(for date: Date) async throws -> [AwanTask] {
        let timeZoneID = await getTimeZoneID()
        let dayKey = LocalDateKey.value(
            for: date,
            timeZoneID: timeZoneID
        )
        let synced = try? await loadRemoteTasks(dayKey: dayKey, timeZoneID: timeZoneID)
        if let synced {
            return synced
        }
        return try await cachedTasks(
            forDay: dayKey,
            timeZoneID: timeZoneID
        )
    }

    public func observeTasks(for date: Date) -> AnyPublisher<[AwanTask], Error> {
        AsyncValuePublisher.make { await self.getTimeZoneID() }
            .flatMap { timeZoneID -> AnyPublisher<[AwanTask], Error> in
                let dayKey = LocalDateKey.value(
                    for: date,
                    timeZoneID: timeZoneID
                )
                let local = self.localDataSource.observeTasks()
                    .combineLatest(self.localSessionDataSource.observeSessions())
                    .map { tasks, sessions in
                        self.tasksForDay(
                            tasks,
                            sessions: sessions,
                            dayKey: dayKey,
                            timeZoneID: timeZoneID
                        )
                    }
                    .eraseToAnyPublisher()
                let remote = AsyncValuePublisher.make {
                    try await self.loadRemoteTasks(
                        dayKey: dayKey,
                        timeZoneID: timeZoneID
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
        timeZoneID: String
    ) async throws -> [AwanTask] {
        let responses = try await remoteTaskDataSource.getTasks(date: dayKey)
        let preferredDuration = await getPreferredSessionDuration()

        // Persist tasks
        let tasks = try responses.map { response in
            try HomeRemoteMapper.task(
                response.task,
                defaultDuration: preferredDuration
            )
        }
        .sorted { $0.id.uuidString < $1.id.uuidString }
        try await localDataSource.upsertTasks(tasks)

        // Persist sessions returned alongside tasks so tasksForDay can find them.
        let sessions = try responses.flatMap { response in
            try response.sessions.map {
                try HomeRemoteMapper.session($0, timeZoneID: timeZoneID)
            }
        }
        try await localSessionDataSource.replaceSessions(
            sessions,
            forDay: dayKey,
            timeZoneID: timeZoneID
        )

        return tasksForDay(
            tasks,
            sessions: sessions,
            dayKey: dayKey,
            timeZoneID: timeZoneID
        )
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

    private func getTimeZoneID() async -> String {
        (try? await localProfileDataSource.fetchProfile())?.preferences.timezone ?? TimeZone.current.identifier
    }

    private func getPreferredSessionDuration() async -> Int {
        (try? await localProfileDataSource.fetchProfile())?.preferences.preferredSessionDuration ?? 30
    }

    public func addTask(
        _ task: AwanTask,
        sessionZoneID: UUID?,
        startsAt: Date?,
        durationMinutes: Int,
        timeZoneID: String
    ) async throws -> (task: AwanTask, sessions: [Session]) {
        let sessionPayloads: [CreateTaskWithSessionsRequestDTO.SessionPayload]?
        if let start = startsAt {
            let end = start.addingTimeInterval(TimeInterval(durationMinutes * 60))
            sessionPayloads = [
                CreateTaskWithSessionsRequestDTO.SessionPayload(
                    zoneId: sessionZoneID,
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
                goalId: task.goalID,
                categoryId: task.category?.id
            ),
            sessions: sessionPayloads
        )

        let response = try await remoteSessionDataSource.createTaskWithSessions(request: request)
        let acceptedTask = try HomeRemoteMapper.task(
            response.task,
            defaultDuration: durationMinutes
        )
        let acceptedSessions = try response.sessions.map {
            try HomeRemoteMapper.session(
                $0,
                timeZoneID: timeZoneID
            )
        }

        try await localDataSource.addTask(acceptedTask)
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
                isSplittable: task.isSplittable,
                categoryID: task.category?.id
            )
        )
        let accepted = try HomeRemoteMapper.task(
            response,
            defaultDuration: task.duration.minutes
        )
        try await localDataSource.updateTask(accepted)
        let timeZoneID = await getTimeZoneID()
        let sessions = try await remoteSessionDataSource.getTaskSessions(taskID: task.id)
            .map {
                try HomeRemoteMapper.session(
                    $0,
                    timeZoneID: timeZoneID
                )
            }
        try await localSessionDataSource.deleteSessions(taskID: task.id)
        for session in sessions {
            try await localSessionDataSource.addSession(session)
        }
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
            duration: task.duration,
            isSplittable: task.isSplittable,
            mandatory: task.mandatory,
            estimatedPoints: task.estimatedPoints,
            dependencyIDs: dependencyIDs,
            category: task.category
        )
    }
}

import Combine
import Domain
import Foundation

public struct DefaultSessionRepository: SessionRepository {
    private let localDataSource: any LocalSessionDataSource
    private let localTaskDataSource: any LocalTaskDataSource
    private let localProfileDataSource: any LocalUserProfileDataSource
    private let remoteDataSource: any RemoteSessionDataSourceProtocol

    public init(
        localDataSource: any LocalSessionDataSource,
        localTaskDataSource: any LocalTaskDataSource,
        localProfileDataSource: any LocalUserProfileDataSource,
        remoteDataSource: any RemoteSessionDataSourceProtocol
    ) {
        self.localDataSource = localDataSource
        self.localTaskDataSource = localTaskDataSource
        self.localProfileDataSource = localProfileDataSource
        self.remoteDataSource = remoteDataSource
    }

    public func fetchSessions() async throws -> [Session] {
        try await localDataSource.fetchSessions()
    }
    public func observeSessions(taskIDs: [UUID]) -> AnyPublisher<[Session], Error> {
        let local = localDataSource.observeSessions()
            .map { sessions in
                sessions.filter { taskIDs.contains($0.taskID) }
            }
            .eraseToAnyPublisher()
        let remote = AsyncValuePublisher.make {
            try await loadRemoteSessions(taskIDs: taskIDs)
        }
        .catch { _ in Empty<[Session], Error>() }
        return local
            .merge(with: remote)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private func loadRemoteSessions(taskIDs: [UUID]) async throws -> [Session] {
        guard let profile = try await localProfileDataSource.fetchProfile() else {
            throw RemoteDomainMappingError.missingField("cachedProfile")
        }
        var sessionsByTaskID: [UUID: [Session]] = [:]
        for start in stride(from: 0, to: taskIDs.count, by: 6) {
            let end = min(start + 6, taskIDs.count)
            let batch = Array(taskIDs[start..<end])
            let values = try await withThrowingTaskGroup(
                of: (UUID, [Session]).self
            ) { group in
                for taskID in batch {
                    group.addTask {
                        let dtos = try await remoteDataSource.getTaskSessions(taskID: taskID)
                        return (
                            taskID,
                            try dtos.map {
                                try HomeRemoteMapper.session(
                                    $0,
                                    taskID: taskID,
                                    timeZoneID: profile.preferences.timezone
                                )
                            }
                        )
                    }
                }
                var loaded: [(UUID, [Session])] = []
                for try await value in group {
                    loaded.append(value)
                }
                return loaded
            }
            for (taskID, sessions) in values {
                sessionsByTaskID[taskID] = sessions
            }
        }

        let sessions = sessionsByTaskID.values.flatMap { $0 }
        try await localDataSource.replaceAllSessions(sessions)
        for taskID in taskIDs {
            guard let task = try await localTaskDataSource.fetchTask(id: taskID) else { continue }
            let inferredZoneID = sessionsByTaskID[taskID]?
                .sorted { $0.timeRange.start < $1.timeRange.start }
                .compactMap(\.zoneID)
                .first
            guard let inferredZoneID, inferredZoneID != task.zoneID else { continue }
            try await localTaskDataSource.updateTask(
                replacingZone(of: task, with: inferredZoneID)
            )
        }
        return sessions
    }
    public func addSession(_ session: Session) async throws {
        try await localDataSource.addSession(session)
    }
    public func updateSession(_ session: Session) async throws {
        guard let profile = try await localProfileDataSource.fetchProfile() else {
            throw RemoteDomainMappingError.missingField("cachedProfile")
        }
        guard let original = try await localDataSource.fetchSessions()
            .first(where: { $0.id == session.id }) else {
            throw SchedulingError.entityNotFound(id: session.id)
        }
        let timeZoneID = profile.preferences.timezone
        let timeChanged = original.timeRange != session.timeRange
        let statusChanged = original.status != session.status
        let lockChanged = original.blocking != session.blocking
        guard timeChanged || statusChanged || lockChanged else { return }

        var response: SessionResponseDTO
        if timeChanged {
            response = try await remoteDataSource.updateSession(
                sessionID: session.id,
                request: updateRequest(for: session, timeZoneID: timeZoneID)
            )
        } else if statusChanged {
            response = try await remoteDataSource.updateSessionStatus(
                sessionID: session.id,
                status: remoteStatus(session.status)
            )
        } else if session.blocking {
            response = try await remoteDataSource.lockSession(sessionID: session.id)
        } else {
            response = try await remoteDataSource.unlockSession(sessionID: session.id)
        }

        if lockChanged, timeChanged || statusChanged {
            do {
                response = if session.blocking {
                    try await remoteDataSource.lockSession(sessionID: session.id)
                } else {
                    try await remoteDataSource.unlockSession(sessionID: session.id)
                }
            } catch {
                if timeChanged {
                    _ = try? await remoteDataSource.updateSession(
                        sessionID: original.id,
                        request: updateRequest(for: original, timeZoneID: timeZoneID)
                    )
                }
                throw error
            }
        }
        let accepted = try HomeRemoteMapper.session(
            response,
            taskID: original.taskID,
            timeZoneID: timeZoneID
        )
        try await localDataSource.updateSession(accepted)
    }
    public func deleteSession(id: UUID) async throws {
        try await remoteDataSource.deleteSession(sessionID: id)
        try await localDataSource.deleteSession(id: id)
    }
    public func deleteSessions(taskID: UUID) async throws {
        try await localDataSource.deleteSessions(taskID: taskID)
    }
    public func deleteAllSessions() async throws {
        try await localDataSource.deleteAllSessions()
    }

    private func updateRequest(
        for session: Session,
        timeZoneID: String
    ) -> UpdateSessionRequestDTO {
        UpdateSessionRequestDTO(
            start: HomeRemoteMapper.formatDateTime(
                session.timeRange.start,
                timeZoneID: timeZoneID
            ),
            end: HomeRemoteMapper.formatDateTime(
                session.timeRange.end,
                timeZoneID: timeZoneID
            ),
            status: remoteStatus(session.status)
        )
    }

    private func remoteStatus(_ status: Session.Status) -> String {
        switch status {
        case .planned: "SCHEDULED"
        case .completed: "COMPLETED"
        case .missed: "SKIPPED"
        case .cancelled: "CANCELLED"
        }
    }

    private func replacingZone(of task: AwanTask, with zoneID: UUID) -> AwanTask {
        AwanTask(
            id: task.id,
            title: task.title,
            description: task.description,
            status: task.status,
            goalID: task.goalID,
            zoneID: zoneID,
            duration: task.duration,
            isSplittable: task.isSplittable,
            mandatory: task.mandatory,
            estimatedPoints: task.estimatedPoints,
            dependencyIDs: task.dependencyIDs
        )
    }
}

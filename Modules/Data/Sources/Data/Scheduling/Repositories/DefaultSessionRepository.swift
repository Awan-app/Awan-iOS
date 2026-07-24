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

    public func fetchSessions(for date: Date) async throws -> [Session] {
        let profile = try await requireProfile()
        let dayKey = LocalDateKey.value(
            for: date,
            timeZoneID: profile.preferences.timezone
        )
        return try await localDataSource.fetchSessions()
            .filter {
                LocalDateKey.value(
                    for: $0.timeRange.start,
                    timeZoneID: profile.preferences.timezone
                ) == dayKey
            }
            .sorted(by: sessionOrder)
    }

    public func observeSessions(for date: Date) -> AnyPublisher<[Session], Error> {
        AsyncValuePublisher.make { try await requireProfile() }
            .flatMap { profile -> AnyPublisher<[Session], Error> in
                let dayKey = LocalDateKey.value(
                    for: date,
                    timeZoneID: profile.preferences.timezone
                )
                let local = localDataSource.observeSessions()
                    .map { sessions in
                        sessions
                            .filter {
                                LocalDateKey.value(
                                    for: $0.timeRange.start,
                                    timeZoneID: profile.preferences.timezone
                                ) == dayKey
                            }
                            .sorted(by: sessionOrder)
                    }
                    .eraseToAnyPublisher()
                let remote = AsyncValuePublisher.make {
                    try await loadRemoteSessions(
                        dayKey: dayKey,
                        profile: profile
                    )
                }
                .catch { _ in Empty<[Session], Error>() }
                .eraseToAnyPublisher()
                return local
                    .merge(with: remote)
                    .removeDuplicates()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func loadRemoteSessions(
        dayKey: String,
        profile: UserProfile
    ) async throws -> [Session] {
        let sessions = try await remoteDataSource.getSessions(date: dayKey)
            .map {
                try HomeRemoteMapper.session(
                    $0,
                    timeZoneID: profile.preferences.timezone
                )
            }
            .sorted(by: sessionOrder)
        try await localDataSource.replaceSessions(
            sessions,
            forDay: dayKey,
            timeZoneID: profile.preferences.timezone
        )
        let sessionsByTaskID = Dictionary(grouping: sessions, by: \.taskID)
        for taskID in sessionsByTaskID.keys {
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

    private func requireProfile() async throws -> UserProfile {
        guard let profile = try await localProfileDataSource.fetchProfile() else {
            throw RemoteDomainMappingError.missingField("cachedProfile")
        }
        return profile
    }

    private func sessionOrder(_ lhs: Session, _ rhs: Session) -> Bool {
        if lhs.timeRange.start != rhs.timeRange.start {
            return lhs.timeRange.start < rhs.timeRange.start
        }
        return lhs.id.uuidString < rhs.id.uuidString
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

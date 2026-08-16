import Combine
import Domain
import Foundation

public struct DefaultSessionRepository: SessionRepository {
    private let localDataSource: any LocalSessionDataSource
    private let localProfileDataSource: any LocalUserProfileDataSource
    private let remoteDataSource: any RemoteSessionDataSourceProtocol

    public init(
        localDataSource: any LocalSessionDataSource,
        localProfileDataSource: any LocalUserProfileDataSource,
        remoteDataSource: any RemoteSessionDataSourceProtocol
    ) {
        self.localDataSource = localDataSource
        self.localProfileDataSource = localProfileDataSource
        self.remoteDataSource = remoteDataSource
    }

    public func fetchSessions() async throws -> [Session] {
        try await localDataSource.fetchSessions()
    }

    public func fetchSessions(taskID: UUID) async throws -> [Session] {
        let timeZoneID = await getTimeZoneID()
        let sessions = try await remoteDataSource.getTaskSessions(taskID: taskID)
            .map {
                try HomeRemoteMapper.session($0, timeZoneID: timeZoneID)
            }
            .sorted(by: sessionOrder)
        try await localDataSource.deleteSessions(taskID: taskID)
        for session in sessions {
            try await localDataSource.addSession(session)
        }
        return sessions
    }

    public func fetchSessions(for date: Date) async throws -> [Session] {
        let timeZoneID = await getTimeZoneID()
        let dayKey = LocalDateKey.value(
            for: date,
            timeZoneID: timeZoneID
        )
        return try await localDataSource.fetchSessions()
            .filter {
                LocalDateKey.value(
                    for: $0.timeRange.start,
                    timeZoneID: timeZoneID
                ) == dayKey
            }
            .sorted(by: sessionOrder)
    }

    public func observeSessions() -> AnyPublisher<[Session], Error> {
        localDataSource.observeSessions()
    }

    public func observeSessions(for date: Date) -> AnyPublisher<[Session], Error> {
        AsyncValuePublisher.make { await getTimeZoneID() }
            .flatMap { timeZoneID -> AnyPublisher<[Session], Error> in
                let dayKey = LocalDateKey.value(
                    for: date,
                    timeZoneID: timeZoneID
                )
                let local = localDataSource.observeSessions()
                    .map { sessions in
                        sessions
                            .filter {
                                LocalDateKey.value(
                                    for: $0.timeRange.start,
                                    timeZoneID: timeZoneID
                                ) == dayKey
                            }
                            .sorted(by: sessionOrder)
                    }
                    .eraseToAnyPublisher()
                let remote = AsyncValuePublisher.make {
                    try await loadRemoteSessions(
                        dayKey: dayKey,
                        timeZoneID: timeZoneID
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
        timeZoneID: String
    ) async throws -> [Session] {
        let sessions = try await remoteDataSource.getSessions(date: dayKey)
            .map {
                try HomeRemoteMapper.session(
                    $0,
                    timeZoneID: timeZoneID
                )
            }
            .sorted(by: sessionOrder)
        try await localDataSource.replaceSessions(
            sessions,
            forDay: dayKey,
            timeZoneID: timeZoneID
        )
        return sessions
    }

    private func getTimeZoneID() async -> String {
        (try? await localProfileDataSource.fetchProfile())?.preferences.timezone ?? TimeZone.current.identifier
    }

    private func sessionOrder(_ lhs: Session, _ rhs: Session) -> Bool {
        if lhs.timeRange.start != rhs.timeRange.start {
            return lhs.timeRange.start < rhs.timeRange.start
        }
        return lhs.id.uuidString < rhs.id.uuidString
    }
    public func createSession(
        taskID: UUID,
        timeRange: TimeRange,
        zoneID: UUID?
    ) async throws -> Session {
        let timeZoneID = await getTimeZoneID()
        let responses = try await remoteDataSource.createTaskSessions(
            taskID: taskID,
            request: CreateTaskSessionsRequestDTO(
                sessions: [
                    CreateTaskWithSessionsRequestDTO.SessionPayload(
                        zoneId: zoneID,
                        start: HomeRemoteMapper.formatDateTime(
                            timeRange.start,
                            timeZoneID: timeZoneID
                        ),
                        end: HomeRemoteMapper.formatDateTime(
                            timeRange.end,
                            timeZoneID: timeZoneID
                        )
                    )
                ]
            )
        )
        let acceptedSessions = try responses.map {
            try HomeRemoteMapper.session($0, timeZoneID: timeZoneID)
        }
        guard let createdSession = acceptedSessions.first else {
            throw SchedulingError.entityNotFound(id: taskID)
        }
        for session in acceptedSessions {
            try await localDataSource.addSession(session)
        }
        return createdSession
    }

    public func addSession(_ session: Session) async throws {
        try await localDataSource.addSession(session)
    }
    public func upsertSessions(_ sessions: [Session]) async throws {
        try await localDataSource.upsertSessions(sessions)
    }
    public func updateSession(_ session: Session) async throws {
        let timeZoneID = await getTimeZoneID()
        guard let original = try await localDataSource.fetchSessions()
            .first(where: { $0.id == session.id }) else {
            throw SchedulingError.entityNotFound(id: session.id)
        }
        let timeChanged = original.timeRange != session.timeRange
        let lockChanged = original.blocking != session.blocking
        guard timeChanged || lockChanged else { return }

        var response: SessionResponseDTO

        if timeChanged {
            response = try await remoteDataSource.updateSession(
                sessionID: session.id,
                request: updateRequest(
                    for: session,
                    timeZoneID: timeZoneID
                )
            )
        } else {
            response = if session.blocking {
                try await remoteDataSource.lockSession(
                    sessionID: session.id
                )
            } else {
                try await remoteDataSource.unlockSession(
                    sessionID: session.id
                )
            }
        }

        if timeChanged && lockChanged {
            do {
                response = if session.blocking {
                    try await remoteDataSource.lockSession(
                        sessionID: session.id
                    )
                } else {
                    try await remoteDataSource.unlockSession(
                        sessionID: session.id
                    )
                }
            } catch {
                _ = try? await remoteDataSource.updateSession(
                    sessionID: original.id,
                    request: updateRequest(
                        for: original,
                        timeZoneID: timeZoneID
                    )
                )

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
    public func completeSession(
        id: UUID
    ) async throws -> SessionCompletionResult {
        let timeZoneID = await getTimeZoneID()

        let response = try await remoteDataSource.completeSession(
            sessionID: id
        )

        let session = try HomeRemoteMapper.session(
            response.session,
            timeZoneID: timeZoneID
        )

        let reward = HomeRemoteMapper.completionReward(
            response.reward
        )

        try await localDataSource.updateSession(session)

        return SessionCompletionResult(
            session: session,
            reward: reward
        )
    }
    public func uncompleteSession(
        id: UUID
    ) async throws -> Session {
        let timeZoneID = await getTimeZoneID()

        let response = try await remoteDataSource.uncompleteSession(
            sessionID: id
        )

        let session = try HomeRemoteMapper.session(
            response,
            timeZoneID: timeZoneID
        )

        try await localDataSource.updateSession(session)

        return session
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
            status: nil
        )
    }
}

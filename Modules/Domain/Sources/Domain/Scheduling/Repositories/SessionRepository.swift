import Combine
import Foundation

public protocol SessionRepository: Sendable {
    func fetchSessions() async throws -> [Session]
    func fetchSessions(taskID: UUID) async throws -> [Session]
    func fetchSessions(for date: Date) async throws -> [Session]
    func observeSessions() -> AnyPublisher<[Session], Error>
    func observeSessions(for date: Date) -> AnyPublisher<[Session], Error>
    func createSession(
        taskID: UUID,
        timeRange: TimeRange,
        zoneID: UUID?
    ) async throws -> Session
    func addSession(_ session: Session) async throws
    func upsertSessions(_ sessions: [Session]) async throws
    func updateSession(_ session: Session) async throws
    func deleteSession(id: UUID) async throws
    func deleteSessions(taskID: UUID) async throws
    func deleteAllSessions() async throws
    func completeSession(
        id: UUID
    ) async throws -> SessionCompletionResult
    func uncompleteSession(
        id: UUID
    ) async throws -> Session
}

public extension SessionRepository {
    func upsertSessions(_ sessions: [Session]) async throws {
        let existingIDs = Set(try await fetchSessions().map(\.id))
        for session in sessions {
            if existingIDs.contains(session.id) {
                try await updateSession(session)
            } else {
                try await addSession(session)
            }
        }
    }

    func createSession(
        taskID: UUID,
        timeRange: TimeRange,
        zoneID: UUID? = nil
    ) async throws -> Session {
        let session = Session(
            id: UUID(),
            taskID: taskID,
            zoneID: zoneID,
            timeRange: timeRange,
            blocking: false,
            status: .planned
        )
        try await addSession(session)
        return session
    }

    func fetchSessions(taskID: UUID) async throws -> [Session] {
        try await fetchSessions()
            .filter { $0.taskID == taskID }
            .sorted {
                if $0.timeRange.start != $1.timeRange.start {
                    return $0.timeRange.start < $1.timeRange.start
                }
                return $0.id.uuidString < $1.id.uuidString
            }
    }

    func fetchSessions(for date: Date) async throws -> [Session] {
        try await fetchSessions().filter {
            Calendar.current.isDate($0.timeRange.start, inSameDayAs: date)
        }
    }

    func observeSessions() -> AnyPublisher<[Session], Error> {
        AsyncValuePublisher.make { try await fetchSessions() }
    }

    func observeSessions(for date: Date) -> AnyPublisher<[Session], Error> {
        AsyncValuePublisher.make { try await fetchSessions(for: date) }
    }
}

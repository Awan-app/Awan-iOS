import Combine
import Foundation

public protocol SessionRepository: Sendable {
    func fetchSessions() async throws -> [Session]
    func fetchSessions(for date: Date) async throws -> [Session]
    func observeSessions(for date: Date) -> AnyPublisher<[Session], Error>
    func addSession(_ session: Session) async throws
    func updateSession(_ session: Session) async throws
    func deleteSession(id: UUID) async throws
    func deleteSessions(taskID: UUID) async throws
    func deleteAllSessions() async throws
}

public extension SessionRepository {
    func fetchSessions(for date: Date) async throws -> [Session] {
        try await fetchSessions().filter {
            Calendar.current.isDate($0.timeRange.start, inSameDayAs: date)
        }
    }

    func observeSessions(for date: Date) -> AnyPublisher<[Session], Error> {
        AsyncValuePublisher.make { try await fetchSessions(for: date) }
    }
}

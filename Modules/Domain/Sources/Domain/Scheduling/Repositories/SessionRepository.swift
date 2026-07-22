import Combine
import Foundation

public protocol SessionRepository: Sendable {
    func fetchSessions() async throws -> [Session]
    func observeSessions(taskIDs: [UUID]) -> AnyPublisher<[Session], Error>
    func addSession(_ session: Session) async throws
    func updateSession(_ session: Session) async throws
    func deleteSession(id: UUID) async throws
    func deleteSessions(taskID: UUID) async throws
    func deleteAllSessions() async throws
}

public extension SessionRepository {
    func observeSessions(taskIDs: [UUID]) -> AnyPublisher<[Session], Error> {
        AsyncValuePublisher.make {
            try await fetchSessions().filter { taskIDs.contains($0.taskID) }
        }
    }
}

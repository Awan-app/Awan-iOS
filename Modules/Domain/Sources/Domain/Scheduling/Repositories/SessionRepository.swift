import Foundation

public protocol SessionRepository: Sendable {
    func fetchSessions() async throws -> [Session]
    func addSession(_ session: Session) async throws
    func updateSession(_ session: Session) async throws
    func deleteSession(id: UUID) async throws
    func deleteSessions(taskID: UUID) async throws
    func deleteAllSessions() async throws
}

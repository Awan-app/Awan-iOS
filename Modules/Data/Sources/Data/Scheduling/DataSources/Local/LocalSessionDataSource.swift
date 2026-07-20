import Foundation

public protocol LocalSessionDataSource: Sendable {
    func fetchSessions() async throws -> [SessionRecord]
    func addSession(_ session: SessionRecord) async throws
    func updateSession(_ session: SessionRecord) async throws
    func deleteSession(id: UUID) async throws
    func deleteSessions(taskID: UUID) async throws
    func deleteAllSessions() async throws
}

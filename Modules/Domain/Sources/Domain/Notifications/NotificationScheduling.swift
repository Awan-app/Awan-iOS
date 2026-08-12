import Foundation

public enum NotificationLeadTime: Int, Sendable, CaseIterable {
    case atStart = 0
    case fiveMin = 5
    case tenMin = 10
    case fifteenMin = 15
}

public protocol NotificationScheduling: Sendable {
    func requestAuthorization() async throws -> Bool
    func scheduleSessions(_ sessions: [Session], taskTitlesByID: [UUID: String]) async
    func scheduleGoals(_ goals: [Goal]) async
    func cancelNotifications(for sessionIDs: [UUID]) async
    func cancelNotifications(for goalID: UUID) async
    func cancelAll() async
}

//
//  NotificationScheduler.swift
//  Awan
//

import Foundation
import Domain

@MainActor
public final class NotificationScheduler {
    private let notificationService: any NotificationScheduling

    public init(notificationService: any NotificationScheduling) {
        self.notificationService = notificationService
    }

    public var isNotificationsEnabled: Bool {
        if UserDefaults.standard.object(forKey: "isNotificationsEnabled") == nil { return true }
        return UserDefaults.standard.bool(forKey: "isNotificationsEnabled")
    }

    public func syncSessions(_ sessions: [Session], taskTitlesByID: [UUID: String]) {
        guard isNotificationsEnabled else {
            Task { await notificationService.cancelAll() }
            return
        }
        Task {
            await notificationService.scheduleSessions(sessions, taskTitlesByID: taskTitlesByID)
        }
    }

    public func syncGoals(_ goals: [Goal]) {
        guard isNotificationsEnabled else { return }
        Task {
            await notificationService.scheduleGoals(goals)
        }
    }

    public func cancelGoal(_ goalID: UUID) {
        Task {
            await notificationService.cancelNotifications(for: goalID)
        }
    }
    
    public func requestAuthorization() async throws -> Bool {
        try await notificationService.requestAuthorization()
    }
}

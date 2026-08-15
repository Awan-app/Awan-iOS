//
//  LocalNotificationService.swift
//  Awan
//

import Foundation
import UserNotifications
import Domain
import Common
import Combine

public final class LocalNotificationService: NotificationScheduling, @unchecked Sendable {
    private var center: UNUserNotificationCenter { .current() }
    private let userProfileRepository: any UserProfileRepository

    public init(userProfileRepository: any UserProfileRepository) {
        self.userProfileRepository = userProfileRepository
    }

    public func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound])
    }

    public func scheduleSessions(_ sessions: [Session], taskTitlesByID: [UUID: String]) async {
        let pending = await center.pendingNotificationRequests()
        let sessionNotificationIDs = pending.map(\.identifier).filter { $0.starts(with: "session-") }
        center.removePendingNotificationRequests(withIdentifiers: sessionNotificationIDs)

        let now = Date()
        let futureSessions = sessions.filter { $0.status == .planned && $0.timeRange.start > now }

        for session in futureSessions {
            guard let taskTitle = taskTitlesByID[session.taskID] else { continue }

            let leadTime: TimeInterval = 5 * 60
            if session.timeRange.start.addingTimeInterval(-leadTime) > now {
                scheduleSessionNotification(
                    id: "session-start-\(session.id.uuidString)",
                    title: L10n.Notifications.sessionStartTitle,
                    body: L10n.Notifications.sessionStartBody(taskTitle),
                    date: session.timeRange.start.addingTimeInterval(-leadTime),
                    sessionID: session.id
                )
            }

            // Schedule the exact start time notification
            scheduleSessionNotification(
                id: "session-now-\(session.id.uuidString)",
                title: L10n.Notifications.sessionNowTitle,
                body: L10n.Notifications.sessionNowBody(taskTitle),
                date: session.timeRange.start,
                sessionID: session.id
            )
        }
    }

    public func scheduleGoals(_ goals: [Goal]) async {
        let pending = await center.pendingNotificationRequests()
        let goalNotificationIDs = pending.map(\.identifier).filter { $0.starts(with: "goal-") }
        center.removePendingNotificationRequests(withIdentifiers: goalNotificationIDs)

        for goal in goals {
            guard goal.status == .active, let deadline = goal.deadline else { continue }
            
            let now = Date()
            guard deadline > now else { continue }

            // Fetch user wake time for the day-of notification
            let wakeHour = await fetchWakeHour()

            // 7 days before
            if let d7 = Calendar.current.date(byAdding: .day, value: -7, to: deadline), d7 > now {
                scheduleGoalNotification(
                    id: "goal-7d-\(goal.id.uuidString)",
                    title: L10n.Notifications.goalDeadline7dTitle,
                    body: L10n.Notifications.goalDeadline7dBody(goal.name),
                    date: d7,
                    goalID: goal.id
                )
            }

            // 1 day before
            if let d1 = Calendar.current.date(byAdding: .day, value: -1, to: deadline), d1 > now {
                scheduleGoalNotification(
                    id: "goal-1d-\(goal.id.uuidString)",
                    title: L10n.Notifications.goalDeadline1dTitle,
                    body: L10n.Notifications.goalDeadline1dBody(goal.name),
                    date: d1,
                    goalID: goal.id
                )
            }

            // Day-of at wake time
            let dayOf = Calendar.current.startOfDay(for: deadline)
            if let dayOfAtWake = Calendar.current.date(bySettingHour: wakeHour, minute: 0, second: 0, of: dayOf), dayOfAtWake > now {
                scheduleGoalNotification(
                    id: "goal-today-\(goal.id.uuidString)",
                    title: L10n.Notifications.goalDeadlineTodayTitle,
                    body: L10n.Notifications.goalDeadlineTodayBody(goal.name),
                    date: dayOfAtWake,
                    goalID: goal.id
                )
            }
        }
    }

    public func cancelNotifications(for sessionIDs: [UUID]) async {
        let identifiers = sessionIDs.flatMap { [
            "session-start-\($0.uuidString)",
            "session-now-\($0.uuidString)"
        ] }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    public func cancelNotifications(for goalID: UUID) async {
        let identifiers = [
            "goal-7d-\(goalID.uuidString)",
            "goal-1d-\(goalID.uuidString)",
            "goal-today-\(goalID.uuidString)"
        ]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    public func cancelAll() async {
        center.removeAllPendingNotificationRequests()
    }

    // MARK: - Private Helpers

    private func scheduleSessionNotification(id: String, title: String, body: String, date: Date, sessionID: UUID) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = ["sessionID": sessionID.uuidString]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule session notification: \(error)")
            }
        }
    }

    private func scheduleGoalNotification(id: String, title: String, body: String, date: Date, goalID: UUID) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = ["goalID": goalID.uuidString]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule goal notification: \(error)")
            }
        }
    }

    private func fetchWakeHour() async -> Int {
        do {
            let profile = try await userProfileRepository.fetchCurrentUser()
            return profile.preferences.wakeupTime.hour
        } catch {
            return 9 // Fallback to 9 AM
        }
    }
}

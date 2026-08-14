//
//  InboxStateMapper.swift
//  Presentation
//

import Common
import Domain
import Foundation

public struct InboxStateMapper: Sendable {
    private let calendar: Calendar
    private let locale: Locale
    private let sessionStatusFactory = SessionDisplayStatusFactory()

    public init(calendar: Calendar = .current, locale: Locale = .autoupdatingCurrent) {
        self.calendar = calendar
        self.locale = locale
    }

    public func map(
        inboxTasks: [InboxTask],
        now: Date = Date()
    ) -> [InboxTaskItem] {
        inboxTasks.map { mapTask($0, now: now) }
    }

    public func mapTask(_ inboxTask: InboxTask, now: Date = Date()) -> InboxTaskItem {
        let sessionItems = inboxTask.sessions.map { session in
            mapSession(session, now: now)
        }

        let summary = buildSessionsSummary(sessions: inboxTask.sessions, sessionItems: sessionItems)

        return InboxTaskItem(
            id: inboxTask.id,
            title: inboxTask.task.title,
            description: inboxTask.task.description,
            derivedStatus: inboxTask.derivedStatus,
            sessionsSummary: summary,
            sessionItems: sessionItems,
            rawTask: inboxTask.task,
            availableCompletionPoints: availableCompletionPoints(
                task: inboxTask.task,
                sessions: inboxTask.sessions
            )
        )
    }

    private func availableCompletionPoints(
        task: AwanTask,
        sessions: [Session]
    ) -> Int {
        let unrewardedSessionCount = sessions.filter {
            $0.status != .cancelled && $0.firstCompletedAt == nil
        }.count
        return task.estimatedPoints * unrewardedSessionCount
    }

    public func mapSession(_ session: Session, now: Date = Date()) -> InboxSessionItem {
        let displayStatus = deriveSessionDisplayStatus(session: session, now: now)
        let timeRangeText = formatTimeRange(start: session.timeRange.start, end: session.timeRange.end)

        return InboxSessionItem(
            id: session.id,
            timeRangeText: timeRangeText,
            displayStatus: displayStatus,
            underlyingStatus: session.status
        )
    }

    public func deriveSessionDisplayStatus(session: Session, now: Date) -> InboxSessionDisplayStatus {
        sessionStatusFactory.make(session: session, now: now)
    }

    public func formatTimeRange(start: Date, end: Date) -> String {
        var cal = calendar
        cal.locale = locale

        let timeFormatter = DateFormatter()
        timeFormatter.locale = locale
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none

        let startTimeStr = timeFormatter.string(from: start)
        let endTimeStr = timeFormatter.string(from: end)
        let timeRangeStr = "\(startTimeStr)–\(endTimeStr)"

        let dayPrefix: String
        if cal.isDateInToday(start) {
            dayPrefix = L10n.Home.today
        } else if cal.isDateInTomorrow(start) {
            dayPrefix = cal.shortWeekdaySymbols[cal.component(.weekday, from: start) - 1]
        } else if cal.isDateInYesterday(start) {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = locale
            dateFormatter.dateFormat = "EEEE"
            dayPrefix = dateFormatter.string(from: start)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = locale
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            return "\(dateFormatter.string(from: start)), \(timeRangeStr)"
        }

        return "\(dayPrefix), \(timeRangeStr)"
    }

    private func buildSessionsSummary(sessions: [Session], sessionItems: [InboxSessionItem]) -> String {
        guard !sessions.isEmpty else {
            return L10n.Inbox.noSessions
        }

        let completedCount = sessions.filter { $0.status == .completed }.count
        let scheduledCount = sessions.filter { $0.status == .planned }.count

        var parts: [String] = []

        if completedCount > 0 {
            parts.append("\(completedCount) completed")
        }
        if scheduledCount > 0 {
            parts.append("\(scheduledCount) scheduled")
        }

        if parts.isEmpty {
            return sessions.count == 1 ? L10n.Inbox.oneSession : L10n.Inbox.nSessions(sessions.count)
        }

        return parts.joined(separator: " • ")
    }
}

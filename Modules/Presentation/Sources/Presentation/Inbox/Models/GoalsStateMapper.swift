//
//  GoalsStateMapper.swift
//  Presentation
//

import Domain
import Foundation

public struct GoalsStateMapper: Sendable {
    private let locale: Locale

    public init(locale: Locale = .autoupdatingCurrent) {
        self.locale = locale
    }

    public func map(goals: [GoalWithTasks]) -> [GoalProgressItem] {
        goals.map { mapGoal($0) }
    }

    public func mapGoal(_ goalWithTasks: GoalWithTasks) -> GoalProgressItem {
        let tasks = goalWithTasks.tasks
        let total = tasks.count

        let completedCount = tasks.filter { $0.derivedStatus == .completed }.count
        let activeCount    = tasks.filter { $0.derivedStatus == .active    }.count
        let draftedCount   = tasks.filter { $0.derivedStatus == .drafted   }.count
        let cancelledCount = tasks.filter { $0.derivedStatus == .cancelled }.count

        let progressFraction = total > 0 ? Double(completedCount) / Double(total) : 0.0

        let breakdown = GoalTaskBreakdown(
            drafted: draftedCount,
            active: activeCount,
            completed: completedCount,
            cancelled: cancelledCount
        )

        return GoalProgressItem(
            id: goalWithTasks.goal.id,
            title: goalWithTasks.goal.name,
            description: goalWithTasks.goal.description,
            deadlineText: goalWithTasks.goal.deadline.map { formatDeadline($0) },
            progressFraction: progressFraction,
            completedCount: completedCount,
            totalCount: total,
            breakdown: breakdown,
            rawGoal: goalWithTasks.goal
        )
    }

    // MARK: - Private

    private func formatDeadline(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

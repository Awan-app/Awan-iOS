//
//  GoalWithTasks.swift
//  Domain
//

import Foundation

public struct GoalWithTasks: Identifiable, Hashable, Sendable {
    public let goal: Goal
    public let tasks: [InboxTask]

    public var id: UUID { goal.id }

    public init(goal: Goal, tasks: [InboxTask]) {
        self.goal = goal
        self.tasks = tasks
    }
}

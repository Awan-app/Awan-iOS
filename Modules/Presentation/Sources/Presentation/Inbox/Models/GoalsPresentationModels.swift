//
//  GoalsPresentationModels.swift
//  Presentation
//

import Domain
import Foundation

// MARK: - Goal breakdown counts

public struct GoalTaskBreakdown: Hashable, Sendable {
    public let drafted: Int
    public let active: Int
    public let completed: Int
    public let cancelled: Int

    public var total: Int { drafted + active + completed + cancelled }

    public init(drafted: Int, active: Int, completed: Int, cancelled: Int) {
        self.drafted = drafted
        self.active = active
        self.completed = completed
        self.cancelled = cancelled
    }
}

// MARK: - Goal card presentation model

public struct GoalProgressItem: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let description: String?
    /// Formatted as "Dec 31" or nil
    public let deadlineText: String?
    /// 0.0–1.0; always 0.0 when totalCount == 0
    public let progressFraction: Double
    public let completedCount: Int
    public let totalCount: Int
    public let breakdown: GoalTaskBreakdown
    public let rawGoal: Goal

    public init(
        id: UUID,
        title: String,
        description: String?,
        deadlineText: String?,
        progressFraction: Double,
        completedCount: Int,
        totalCount: Int,
        breakdown: GoalTaskBreakdown,
        rawGoal: Goal
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.deadlineText = deadlineText
        self.progressFraction = progressFraction
        self.completedCount = completedCount
        self.totalCount = totalCount
        self.breakdown = breakdown
        self.rawGoal = rawGoal
    }
}

// MARK: - Goal task detail presentation model

/// A ready-to-render snapshot of a single task for the Goal Detail task list.
/// Built by `GoalsViewModel`; views must not add any business logic on top.
public struct GoalDetailTaskItem: Identifiable, Equatable, Sendable {
    /// Sequential 1-based display index after dependency ordering.
    public let displayIndex: Int
    /// Whether this task declares one or more in-list dependencies.
    public let isDependent: Bool
    /// Human-readable names of the tasks this task depends on.
    public let dependencyNames: [String]
    /// The underlying domain task.
    public let task: AwanTask

    public var id: UUID { task.id }

    public init(
        displayIndex: Int,
        isDependent: Bool,
        dependencyNames: [String],
        task: AwanTask
    ) {
        self.displayIndex = displayIndex
        self.isDependent = isDependent
        self.dependencyNames = dependencyNames
        self.task = task
    }
}

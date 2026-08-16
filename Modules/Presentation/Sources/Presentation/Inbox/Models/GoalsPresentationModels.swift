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
    public let deadlineText: String?
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


public struct GoalDetailTaskItem: Identifiable, Equatable, Sendable {
    public let displayIndex: Int
    public let isDependent: Bool
    public let dependencyIndices: [Int]
    public let task: AwanTask
    public let sessionsSummary: String
    public let sessionItems: [InboxSessionItem]

    public var id: UUID { task.id }

    public init(
        displayIndex: Int,
        isDependent: Bool,
        dependencyIndices: [Int],
        task: AwanTask,
        sessionsSummary: String = "",
        sessionItems: [InboxSessionItem] = []
    ) {
        self.displayIndex = displayIndex
        self.isDependent = isDependent
        self.dependencyIndices = dependencyIndices
        self.task = task
        self.sessionsSummary = sessionsSummary
        self.sessionItems = sessionItems
    }

    public var availableCompletionPoints: Int {
        let unrewardedCount = sessionItems.filter { session in
            session.underlyingStatus != .cancelled
                && !session.hasClaimedReward
        }.count
        return task.estimatedPoints * unrewardedCount
    }

    public var areAllSessionRewardsClaimed: Bool {
        let rewardEligibleSessions = sessionItems.filter {
            $0.underlyingStatus != .cancelled
        }
        return !rewardEligibleSessions.isEmpty
            && rewardEligibleSessions.allSatisfy(\.hasClaimedReward)
    }

    public var asInboxTaskItem: InboxTaskItem {
        let derivedStatus: InboxTaskStatus = {
            if task.completedAt != nil || task.status == .completed {
                return .completed
            } else if task.status == .active {
                return .active
            } else if task.status == .cancelled {
                return .cancelled
            } else {
                return .drafted
            }
        }()

        return InboxTaskItem(
            id: task.id,
            title: task.title,
            description: task.description,
            derivedStatus: derivedStatus,
            sessionsSummary: sessionsSummary,
            sessionItems: sessionItems,
            rawTask: task,
            availableCompletionPoints: availableCompletionPoints,
            areAllSessionRewardsClaimed: areAllSessionRewardsClaimed
        )
    }
}

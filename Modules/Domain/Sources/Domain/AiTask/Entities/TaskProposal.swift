//
//  TaskProposal.swift
//  Domain
//

import Foundation

public enum ProposedTaskDestination: Sendable {
    case schedule
    case inbox
}

public struct TaskProposal: Sendable, Hashable {
    public let sourceSummary: String?
    public let tasks: [ProposedTask]
    public let timestamp: Date

    public init(
        sourceSummary: String?,
        tasks: [ProposedTask],
        timestamp: Date
    ) {
        self.sourceSummary = sourceSummary
        self.tasks = tasks
        self.timestamp = timestamp
    }
}

public struct ProposedTask: Identifiable, Sendable, Hashable {
    public let id: UUID
    public var draft: TaskWithSessionsDraft
    public var aiProposedSessions: [ProposedSession]
    public let reason: String

    public init(
        id: UUID = UUID(),
        draft: TaskWithSessionsDraft,
        aiProposedSessions: [ProposedSession],
        reason: String
    ) {
        self.id = id
        self.draft = draft
        self.aiProposedSessions = aiProposedSessions
        self.reason = reason
    }
}

public struct TaskWithSessionsDraft: Sendable, Hashable {
    public var task: ProposedTaskDetails
    public var sessions: [ProposedSession]

    public init(
        task: ProposedTaskDetails,
        sessions: [ProposedSession]
    ) {
        self.task = task
        self.sessions = sessions
    }
}

public struct ProposedTaskDetails: Sendable, Hashable {
    public var title: String
    public var description: String?
    public var estimatedDuration: Int
    public var mandatory: Bool
    public var estimatedPoints: Int
    public var allowTaskSplitting: Bool
    public var goalId: UUID?
    public var categoryId: UUID?

    public init(
        title: String,
        description: String? = nil,
        estimatedDuration: Int = 60,
        mandatory: Bool = true,
        estimatedPoints: Int = 10,
        allowTaskSplitting: Bool = false,
        goalId: UUID? = nil,
        categoryId: UUID? = nil
    ) {
        self.title = title
        self.description = description
        self.estimatedDuration = estimatedDuration
        self.mandatory = mandatory
        self.estimatedPoints = estimatedPoints
        self.allowTaskSplitting = allowTaskSplitting
        self.goalId = goalId
        self.categoryId = categoryId
    }
}

public struct ProposedSession: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let zoneId: UUID?
    public var start: Date
    public var end: Date
    public let status: String

    public init(
        id: UUID = UUID(),
        zoneId: UUID? = nil,
        start: Date,
        end: Date,
        status: String = "SCHEDULED"
    ) {
        self.id = id
        self.zoneId = zoneId
        self.start = start
        self.end = end
        self.status = status
    }
}

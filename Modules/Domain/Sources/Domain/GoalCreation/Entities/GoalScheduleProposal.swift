import Foundation

public struct GoalScheduleProposal: Equatable, Sendable {
    public let goalID: UUID
    public let proposedSessions: [GoalScheduleSession]
    public let suggestions: [GoalScheduleSuggestion]
    public let unscheduledTasks: [GoalScheduleUnscheduledTask]

    public init(
        goalID: UUID,
        proposedSessions: [GoalScheduleSession],
        suggestions: [GoalScheduleSuggestion],
        unscheduledTasks: [GoalScheduleUnscheduledTask]
    ) {
        self.goalID = goalID
        self.proposedSessions = proposedSessions
        self.suggestions = suggestions
        self.unscheduledTasks = unscheduledTasks
    }
}

public struct GoalScheduleSession: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let taskID: UUID
    public let taskTitle: String
    public let zoneID: UUID?
    public let start: Date
    public let end: Date

    public init(
        id: UUID = UUID(),
        taskID: UUID,
        taskTitle: String,
        zoneID: UUID?,
        start: Date,
        end: Date
    ) {
        self.id = id
        self.taskID = taskID
        self.taskTitle = taskTitle
        self.zoneID = zoneID
        self.start = start
        self.end = end
    }
}

public enum GoalScheduleSuggestionType: Equatable, Sendable {
    case noZone
    case overlap
}

public struct GoalScheduleSuggestion: Identifiable, Equatable, Sendable {
    public var id: UUID { session.id }
    public let session: GoalScheduleSession
    public let type: GoalScheduleSuggestionType
    public let reason: String
    public let overlap: GoalScheduleOverlapInfo?

    public init(
        session: GoalScheduleSession,
        type: GoalScheduleSuggestionType,
        reason: String,
        overlap: GoalScheduleOverlapInfo?
    ) {
        self.session = session
        self.type = type
        self.reason = reason
        self.overlap = overlap
    }
}

public struct GoalScheduleOverlapInfo: Equatable, Sendable {
    public let taskTitle: String
    public let start: Date
    public let end: Date
    public let mandatory: Bool
    public let points: Int

    public init(
        taskTitle: String,
        start: Date,
        end: Date,
        mandatory: Bool,
        points: Int
    ) {
        self.taskTitle = taskTitle
        self.start = start
        self.end = end
        self.mandatory = mandatory
        self.points = points
    }
}

public struct GoalScheduleUnscheduledTask: Identifiable, Equatable, Sendable {
    public var id: UUID { taskID }
    public let taskID: UUID
    public let taskTitle: String
    public let message: String

    public init(taskID: UUID, taskTitle: String, message: String) {
        self.taskID = taskID
        self.taskTitle = taskTitle
        self.message = message
    }
}

public struct GoalScheduleConfirmationItem: Equatable, Sendable {
    public let taskID: UUID
    public let zoneID: UUID?
    public let start: Date
    public let end: Date

    public init(taskID: UUID, zoneID: UUID?, start: Date, end: Date) {
        self.taskID = taskID
        self.zoneID = zoneID
        self.start = start
        self.end = end
    }
}

public struct ConfirmedGoalScheduleSession: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let taskID: UUID
    public let zoneID: UUID?
    public let start: Date
    public let end: Date

    public init(
        id: UUID,
        taskID: UUID,
        zoneID: UUID?,
        start: Date,
        end: Date
    ) {
        self.id = id
        self.taskID = taskID
        self.zoneID = zoneID
        self.start = start
        self.end = end
    }
}

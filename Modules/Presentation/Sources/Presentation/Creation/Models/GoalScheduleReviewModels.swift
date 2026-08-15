import Domain
import Foundation

public enum GoalScheduleReviewSessionKind: Equatable, Sendable {
    case proposed
    case noZone(reason: String)
    case overlap(reason: String, info: GoalScheduleOverlapInfo?)
    case manual
}

public struct GoalScheduleReviewSession: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let taskID: UUID
    public var zoneID: UUID?
    public var start: Date
    public var end: Date
    public var kind: GoalScheduleReviewSessionKind
    public var isAccepted: Bool
    public var isEdited: Bool

    public init(
        id: UUID,
        taskID: UUID,
        zoneID: UUID?,
        start: Date,
        end: Date,
        kind: GoalScheduleReviewSessionKind,
        isAccepted: Bool,
        isEdited: Bool
    ) {
        self.id = id
        self.taskID = taskID
        self.zoneID = zoneID
        self.start = start
        self.end = end
        self.kind = kind
        self.isAccepted = isAccepted
        self.isEdited = isEdited
    }

    public var isIncluded: Bool {
        return switch kind {
        case .noZone, .overlap:
            isEdited || isAccepted
        case .proposed, .manual:
            true
        }
    }

    public var isManual: Bool {
        if isManuallyEditedSuggestion { return true }
        if case .manual = kind { return true }
        return false
    }

    public var isSuggestion: Bool {
        guard !isManuallyEditedSuggestion else { return false }
        return switch kind {
        case .noZone, .overlap:
            true
        case .proposed, .manual:
            false
        }
    }

    public var isManuallyEditedSuggestion: Bool {
        guard isEdited else { return false }
        return switch kind {
        case .noZone, .overlap:
            true
        case .proposed, .manual:
            false
        }
    }
}

public struct GoalScheduleReviewTask: Identifiable, Equatable, Sendable {
    public var id: UUID { taskID }
    public let taskID: UUID
    public let title: String
    public let estimatedDuration: Int
    public var sessions: [GoalScheduleReviewSession]
    public var unscheduledMessage: String?

    public init(
        taskID: UUID,
        title: String,
        estimatedDuration: Int,
        sessions: [GoalScheduleReviewSession],
        unscheduledMessage: String? = nil
    ) {
        self.taskID = taskID
        self.title = title
        self.estimatedDuration = estimatedDuration
        self.sessions = sessions
        self.unscheduledMessage = unscheduledMessage
    }

    public var isUnresolved: Bool {
        !sessions.contains(where: \.isIncluded)
    }

    public var scheduledSessions: [GoalScheduleReviewSession] {
        sessions.filter { !$0.isSuggestion }
    }

    public var suggestionSessions: [GoalScheduleReviewSession] {
        sessions.filter(\.isSuggestion)
    }
}

public enum GoalScheduleReviewMapper {
    public static func tasks(
        proposal: GoalScheduleProposal,
        confirmedGoal: ConfirmedGoal
    ) -> [GoalScheduleReviewTask] {
        let confirmedTasks = Dictionary(
            uniqueKeysWithValues: confirmedGoal.tasks.map { ($0.id, $0.estimatedDuration) }
        )
        return mapTasks(proposal: proposal, durationsByTaskID: confirmedTasks)
    }

    public static func tasks(
        proposal: GoalScheduleProposal,
        tasks: [AwanTask]
    ) -> [GoalScheduleReviewTask] {
        let taskDurations = Dictionary(
            uniqueKeysWithValues: tasks.map { ($0.id, $0.duration.minutes) }
        )
        return mapTasks(proposal: proposal, durationsByTaskID: taskDurations)
    }

    public static func mapTasks(
        proposal: GoalScheduleProposal,
        durationsByTaskID: [UUID: Int] = [:]
    ) -> [GoalScheduleReviewTask] {
        var tasksByID: [UUID: GoalScheduleReviewTask] = [:]
        var order: [UUID] = []

        func register(
            taskID: UUID,
            title: String,
            unscheduledMessage: String? = nil
        ) {
            if tasksByID[taskID] != nil {
                if let unscheduledMessage {
                    tasksByID[taskID]?.unscheduledMessage = unscheduledMessage
                }
                return
            }
            tasksByID[taskID] = GoalScheduleReviewTask(
                taskID: taskID,
                title: title,
                estimatedDuration: durationsByTaskID[taskID] ?? 60,
                sessions: [],
                unscheduledMessage: unscheduledMessage
            )
            order.append(taskID)
        }

        for session in proposal.proposedSessions {
            register(taskID: session.taskID, title: session.taskTitle)
            tasksByID[session.taskID]?.sessions.append(
                GoalScheduleReviewSession(
                    id: session.id,
                    taskID: session.taskID,
                    zoneID: session.zoneID,
                    start: session.start,
                    end: session.end,
                    kind: .proposed,
                    isAccepted: true,
                    isEdited: false
                )
            )
        }

        for session in proposal.manualSessions {
            register(taskID: session.taskID, title: session.taskTitle)
            tasksByID[session.taskID]?.sessions.append(
                GoalScheduleReviewSession(
                    id: session.id,
                    taskID: session.taskID,
                    zoneID: session.zoneID,
                    start: session.start,
                    end: session.end,
                    kind: .manual,
                    isAccepted: true,
                    isEdited: false
                )
            )
        }

        for suggestion in proposal.suggestions {
            let session = suggestion.session
            register(taskID: session.taskID, title: session.taskTitle)
            let kind: GoalScheduleReviewSessionKind = switch suggestion.type {
            case .noZone:
                .noZone(reason: suggestion.reason)
            case .overlap:
                .overlap(reason: suggestion.reason, info: suggestion.overlap)
            }
            tasksByID[session.taskID]?.sessions.append(
                GoalScheduleReviewSession(
                    id: session.id,
                    taskID: session.taskID,
                    zoneID: session.zoneID,
                    start: session.start,
                    end: session.end,
                    kind: kind,
                    isAccepted: false,
                    isEdited: false
                )
            )
        }

        for task in proposal.unscheduledTasks {
            register(
                taskID: task.taskID,
                title: task.taskTitle,
                unscheduledMessage: task.message
            )
        }

        return order.compactMap { tasksByID[$0] }
    }
}

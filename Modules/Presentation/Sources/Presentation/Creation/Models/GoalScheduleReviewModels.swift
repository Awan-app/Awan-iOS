import Domain
import Foundation

enum GoalScheduleReviewSessionKind: Equatable {
    case proposed
    case noZone(reason: String)
    case overlap(reason: String, info: GoalScheduleOverlapInfo?)
    case manual
}

struct GoalScheduleReviewSession: Identifiable, Equatable {
    let id: UUID
    let taskID: UUID
    var zoneID: UUID?
    var start: Date
    var end: Date
    var kind: GoalScheduleReviewSessionKind
    var isAccepted: Bool
    var isEdited: Bool

    var isIncluded: Bool {
        return switch kind {
        case .noZone, .overlap:
            isEdited || isAccepted
        case .proposed, .manual:
            true
        }
    }

    var isManual: Bool {
        if isManuallyEditedSuggestion { return true }
        if case .manual = kind { return true }
        return false
    }

    var isSuggestion: Bool {
        guard !isManuallyEditedSuggestion else { return false }
        return switch kind {
        case .noZone, .overlap:
            true
        case .proposed, .manual:
            false
        }
    }

    var isManuallyEditedSuggestion: Bool {
        guard isEdited else { return false }
        return switch kind {
        case .noZone, .overlap:
            true
        case .proposed, .manual:
            false
        }
    }
}

struct GoalScheduleReviewTask: Identifiable, Equatable {
    var id: UUID { taskID }
    let taskID: UUID
    let title: String
    let estimatedDuration: Int
    var sessions: [GoalScheduleReviewSession]
    var unscheduledMessage: String?

    var isUnresolved: Bool {
        !sessions.contains(where: \.isIncluded)
    }

    var scheduledSessions: [GoalScheduleReviewSession] {
        sessions.filter { !$0.isSuggestion }
    }

    var suggestionSessions: [GoalScheduleReviewSession] {
        sessions.filter(\.isSuggestion)
    }
}

enum GoalScheduleReviewMapper {
    static func tasks(
        proposal: GoalScheduleProposal,
        confirmedGoal: ConfirmedGoal
    ) -> [GoalScheduleReviewTask] {
        let confirmedTasks = Dictionary(
            uniqueKeysWithValues: confirmedGoal.tasks.map { ($0.id, $0) }
        )
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
            let confirmed = confirmedTasks[taskID]
            tasksByID[taskID] = GoalScheduleReviewTask(
                taskID: taskID,
                title: title,
                estimatedDuration: confirmed?.estimatedDuration ?? 60,
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

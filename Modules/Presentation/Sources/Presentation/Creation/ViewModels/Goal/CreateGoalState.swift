import Domain
import Foundation

enum CreateGoalPhase: Equatable {
    case starter
    case loading
    case conversation([GoalDecompositionBlock])
    case proposal(narration: [String], goal: GoalProposal)
    case confirmingGoal
    case requestingSchedule
    case scheduleReview
    case confirmingSchedule
    case scheduleFailure(String)

    var transitionID: Int {
        switch self {
        case .starter: 0
        case .loading: 1
        case .conversation: 2
        case .proposal: 3
        case .confirmingGoal: 4
        case .requestingSchedule: 5
        case .scheduleReview: 6
        case .confirmingSchedule: 7
        case .scheduleFailure: 8
        }
    }
}

struct CreateGoalState {
    var prompt = ""
    var phase: CreateGoalPhase = .starter
    var sessionID: UUID?
    var isRecording = false
    var errorMessage: String?
    var confirmedGoal: ConfirmedGoal?
    var scheduleTasks: [GoalScheduleReviewTask] = []
    var zoneNames: [UUID: String] = [:]
    var showsUnscheduledDialog = false
    var focusedUnscheduledTaskID: UUID?

    var requiresFullScreen: Bool {
        switch phase {
        case .conversation, .proposal, .scheduleReview, .scheduleFailure:
            true
        case .starter, .loading, .confirmingGoal, .requestingSchedule,
             .confirmingSchedule:
            false
        }
    }

    var hidesModeSwitcher: Bool {
        phase != .starter
    }

    var isBusy: Bool {
        phase == .confirmingGoal
            || phase == .requestingSchedule
            || phase == .confirmingSchedule
    }

    var unresolvedTasks: [GoalScheduleReviewTask] {
        scheduleTasks.filter(\.isUnresolved)
    }
}

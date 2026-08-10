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
        case .proposal, .confirmingGoal, .requestingSchedule, .scheduleReview,
             .confirmingSchedule, .scheduleFailure:
            true
        case .starter, .loading, .conversation:
            false
        }
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

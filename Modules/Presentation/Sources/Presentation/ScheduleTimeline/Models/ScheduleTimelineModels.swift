import Common
import Domain
import Foundation
import SwiftUI

public enum ScheduleTimelineSheet: Identifiable, Hashable {
    case createTask
    case createGoal
    case editTask(UUID)

    public var id: String {
        switch self {
        case .createTask: "create-task"
        case .createGoal: "create-goal"
        case let .editTask(id): "edit-\(id.uuidString)"
        }
    }
}

public enum ScheduleTimelineStatus: Hashable {
    case idle
    case loading
    case ready
}

public struct TimelineZoneItem: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let color: Color
    public let startMinutes: Int
    public let endMinutes: Int
}

public struct TimelineZoneOption: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let color: Color
}

public struct TimelineTaskEditorModel: Identifiable, Hashable {
    public let id: UUID
    public let title: String
    public let durationMinutes: Int
    public let zoneID: UUID?
    public let isSplittable: Bool
    public let blocking: Bool
}

public struct TimelineSessionItem: Identifiable, Hashable {
    public let id: UUID
    public let taskID: UUID
    public let title: String
    public let zoneColor: Color
    public let start: Date
    public let end: Date
    public let startMinutes: Int
    public let durationMinutes: Int
    public let lane: Int
    public let laneCount: Int
    public let blocking: Bool
    public let isMissed: Bool
}

public struct TimelineNudgeAction: Identifiable, Hashable {
    public let title: String
    public let icon: String
    public let color: Color
    let command: ScheduleNudgeCommand

    public var id: String { title }
}

public struct TimelineNudgeModel: Hashable {
    public let title: String
    public let message: String
    public let icon: String
    public let actions: [TimelineNudgeAction]
}

public struct ScheduleTimelineState {
    public var status: ScheduleTimelineStatus
    public var selectedDay: Date
    public var selectedDayTitle: String
    public var scheduledMinutes: Int
    public var activeGoalProgress: Double
    public var weekDays: [Date]
    public var zones: [TimelineZoneItem]
    public var zoneOptions: [TimelineZoneOption]
    public var taskEditorsByID: [UUID: TimelineTaskEditorModel]
    public var timelineItems: [TimelineSessionItem]
    public var presentedSheet: ScheduleTimelineSheet?
    public var activeNudge: TimelineNudgeModel?
    public var errorMessage: String?

    public var isLoading: Bool { status == .loading }

    public static func initial(selectedDay: Date) -> ScheduleTimelineState {
        ScheduleTimelineState(
            status: .idle,
            selectedDay: selectedDay,
            selectedDayTitle: "",
            scheduledMinutes: 0,
            activeGoalProgress: 0,
            weekDays: [],
            zones: [],
            zoneOptions: [],
            taskEditorsByID: [:],
            timelineItems: [],
            presentedSheet: nil,
            activeNudge: nil,
            errorMessage: nil
        )
    }
}

struct ScheduleTimelineContent {
    let selectedDayTitle: String
    let scheduledMinutes: Int
    let activeGoalProgress: Double
    let weekDays: [Date]
    let zones: [TimelineZoneItem]
    let zoneOptions: [TimelineZoneOption]
    let taskEditorsByID: [UUID: TimelineTaskEditorModel]
    let timelineItems: [TimelineSessionItem]
}

enum ScheduleNudgeCommand: Hashable {
    case dismiss
    case applyCandidate(ResolutionCandidate)
    case separateOverlap(OverlappingSessionsRequest)
    case moveOverlap(OverlappingSessionsRequest)
    case shiftGoalChain(ShiftGoalDependencyChainRequest)
    case stackTasks(StackDependentTasksRequest)
    case makeTaskIndependent(MakeTaskIndependentRequest)
    case replanZoneSessions(ReplanZoneSessionsRequest)
    case restoreZone(Zone)
    case keepFixedOverAllocation(FixedOverAllocationRequest)
    case trimFixedOverAllocation(FixedOverAllocationRequest)
    case keepFixedSessionsOutsideZone(KeepFixedSessionsOutsideZoneRequest)
    case moveFixedSessionsIntoZone(MoveFixedSessionsIntoZoneRequest)
    case restoreTaskZone(RestoreTaskZoneRequest)
}

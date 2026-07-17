import Domain
import Foundation

public struct ScheduleTaskSubmission: Hashable {
    public let title: String
    public let durationMinutes: Int
    public let zoneID: UUID?
    public let isSplittable: Bool
    public let blocking: Bool

    public init(
        title: String,
        durationMinutes: Int,
        zoneID: UUID?,
        isSplittable: Bool,
        blocking: Bool
    ) {
        self.title = title
        self.durationMinutes = durationMinutes
        self.zoneID = zoneID
        self.isSplittable = isSplittable
        self.blocking = blocking
    }
}

public struct ScheduleGoalSubmission: Hashable {
    public let name: String
    public let zoneID: UUID
    public let taskDurationMinutes: Int

    public init(name: String, zoneID: UUID, taskDurationMinutes: Int) {
        self.name = name
        self.zoneID = zoneID
        self.taskDurationMinutes = taskDurationMinutes
    }
}

public enum ScheduleTimelineAction: Hashable {
    case appeared
    case selectDay(Date)
    case presentCreateTask
    case presentCreateGoal
    case presentEditTask(UUID)
    case dismissSheet
    case createTask(ScheduleTaskSubmission)
    case updateTask(taskID: UUID, submission: ScheduleTaskSubmission)
    case deleteTask(UUID)
    case createGoal(ScheduleGoalSubmission)
    case moveSession(sessionID: UUID, verticalPoints: CGFloat, hourHeight: CGFloat)
    case performNudgeAction(String)
    case simulate(ScheduleSimulationScenario)
    case resetSimulation
    case dismissError
}

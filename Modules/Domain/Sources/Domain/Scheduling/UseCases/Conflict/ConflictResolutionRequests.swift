import Foundation

public struct OverlappingSessionsRequest: Hashable, Sendable {
    public let firstSessionID: UUID
    public let secondSessionID: UUID

    public init(firstSessionID: UUID, secondSessionID: UUID) {
        self.firstSessionID = firstSessionID
        self.secondSessionID = secondSessionID
    }
}

public struct ShiftGoalDependencyChainRequest: Hashable, Sendable {
    public let goalID: UUID
    public let timeZone: TimeZone

    public init(goalID: UUID, timeZone: TimeZone) {
        self.goalID = goalID
        self.timeZone = timeZone
    }
}

public struct StackDependentTasksRequest: Hashable, Sendable {
    public let missedTaskID: UUID
    public let successorTaskID: UUID

    public init(missedTaskID: UUID, successorTaskID: UUID) {
        self.missedTaskID = missedTaskID
        self.successorTaskID = successorTaskID
    }
}

public struct MakeTaskIndependentRequest: Hashable, Sendable {
    public let taskID: UUID
    public let dependencyID: UUID

    public init(taskID: UUID, dependencyID: UUID) {
        self.taskID = taskID
        self.dependencyID = dependencyID
    }
}

public struct ReplanZoneSessionsRequest: Hashable, Sendable {
    public let zoneID: UUID
    public let sessionIDs: [UUID]
    public let timeZone: TimeZone

    public init(zoneID: UUID, sessionIDs: [UUID], timeZone: TimeZone) {
        self.zoneID = zoneID
        self.sessionIDs = sessionIDs
        self.timeZone = timeZone
    }
}

public struct FixedOverAllocationRequest: Hashable, Sendable {
    public let taskID: UUID
    public let pendingZoneChange: TaskZoneChange?
    public let selectedDay: Date
    public let timeZone: TimeZone

    public init(
        taskID: UUID,
        pendingZoneChange: TaskZoneChange?,
        selectedDay: Date,
        timeZone: TimeZone
    ) {
        self.taskID = taskID
        self.pendingZoneChange = pendingZoneChange
        self.selectedDay = selectedDay
        self.timeZone = timeZone
    }
}

public struct KeepFixedSessionsOutsideZoneRequest: Hashable, Sendable {
    public let taskID: UUID
    public let selectedDay: Date
    public let timeZone: TimeZone

    public init(taskID: UUID, selectedDay: Date, timeZone: TimeZone) {
        self.taskID = taskID
        self.selectedDay = selectedDay
        self.timeZone = timeZone
    }
}

public struct MoveFixedSessionsIntoZoneRequest: Hashable, Sendable {
    public let taskID: UUID
    public let zoneID: UUID
    public let sessionIDs: [UUID]
    public let selectedDay: Date
    public let timeZone: TimeZone

    public init(
        taskID: UUID,
        zoneID: UUID,
        sessionIDs: [UUID],
        selectedDay: Date,
        timeZone: TimeZone
    ) {
        self.taskID = taskID
        self.zoneID = zoneID
        self.sessionIDs = sessionIDs
        self.selectedDay = selectedDay
        self.timeZone = timeZone
    }
}

public struct RestoreTaskZoneRequest: Hashable, Sendable {
    public let taskID: UUID
    public let previousZoneID: UUID?
    public let sessionIDs: [UUID]
    public let selectedDay: Date
    public let timeZone: TimeZone

    public init(
        taskID: UUID,
        previousZoneID: UUID?,
        sessionIDs: [UUID],
        selectedDay: Date,
        timeZone: TimeZone
    ) {
        self.taskID = taskID
        self.previousZoneID = previousZoneID
        self.sessionIDs = sessionIDs
        self.selectedDay = selectedDay
        self.timeZone = timeZone
    }
}

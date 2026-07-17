import Foundation

public enum ScheduleNudge: Hashable, Sendable {
    case overlap(firstSessionID: UUID, secondSessionID: UUID)
    case schedulingIssue(SchedulingIssue)
    case missedDependencyChain(goalID: UUID, missedTaskID: UUID, successorTaskID: UUID)
    case zoneReconfigured(zoneID: UUID, previousZone: Zone, affectedSessionIDs: [UUID])
    case fixedSessionOverAllocation(
        taskID: UUID,
        pendingZoneChange: TaskZoneChange?,
        sessionIDs: [UUID],
        scheduledMinutes: Int,
        taskMinutes: Int,
        canTrim: Bool,
        selectedDay: Date,
        timeZone: TimeZone
    )
    case fixedSessionsOutsideTaskZone(
        taskID: UUID,
        previousZoneID: UUID?,
        zoneID: UUID,
        sessionIDs: [UUID],
        selectedDay: Date,
        timeZone: TimeZone
    )
}

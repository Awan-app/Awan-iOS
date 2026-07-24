import Foundation

enum HomeAction {
    case appeared
    case refresh
    case selectDay(Date)
    case presentSession(UUID)
    case dismissSession
    case moveSession(sessionID: UUID, verticalPoints: CGFloat, hourHeight: CGFloat)
    case rescheduleSession(sessionID: UUID, start: Date)
    case setSessionLock(sessionID: UUID, isLocked: Bool)
    case setSessionCompletion(sessionID: UUID, isCompleted: Bool)
    case deleteSession(UUID)
    case dismissError
    case presentAddTask
    case dismissAddTask
    case dismissNudge
    case createTask(
        title: String,
        description: String?,
        durationMinutes: Int,
        zoneID: UUID?,
        isSplittable: Bool,
        mandatory: Bool,
        startsAt: Date
    )
}

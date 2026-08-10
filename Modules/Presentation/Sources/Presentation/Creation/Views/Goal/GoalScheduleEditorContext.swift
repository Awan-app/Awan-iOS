import Foundation

struct GoalScheduleEditorContext: Identifiable {
    let id = UUID()
    let taskID: UUID
    let sessionID: UUID?
    let start: Date
    let durationMinutes: Int
    let allowsDurationEditing: Bool

    static func edit(session: GoalScheduleReviewSession) -> Self {
        Self(
            taskID: session.taskID,
            sessionID: session.id,
            start: session.start,
            durationMinutes: max(
                1,
                Int(session.end.timeIntervalSince(session.start) / 60)
            ),
            allowsDurationEditing: session.isManual
        )
    }

    static func add(taskID: UUID, estimatedDuration: Int) -> Self {
        Self(
            taskID: taskID,
            sessionID: nil,
            start: Date(),
            durationMinutes: min(max(estimatedDuration, 15), 60),
            allowsDurationEditing: true
        )
    }
}

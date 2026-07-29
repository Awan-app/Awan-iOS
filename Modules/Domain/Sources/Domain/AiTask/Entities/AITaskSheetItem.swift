import Foundation

public struct AITaskSheetItem: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let task: AwanTask
    public let startTime: Date
    public let sessions: [Session]

    public var endTime: Date {
        startTime.addingTimeInterval(Double(task.duration.minutes) * 60)
    }

    public init(task: AwanTask, startTime: Date = Date(), sessions: [Session] = []) {
        self.id = task.id
        self.task = task
        self.startTime = startTime
        self.sessions = sessions
    }
}

import Foundation

public struct AITaskSheetItem: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let task: AwanTask
    public let startTime: Date
    public let sessions: [AiProposedSession]
    public let reason: String?

    public var endTime: Date {
        startTime.addingTimeInterval(Double(task.duration.minutes) * 60)
    }

    public init(task: AwanTask, startTime: Date = Date(), sessions: [AiProposedSession] = [], reason: String? = nil) {
        self.id = task.id
        self.task = task
        self.startTime = startTime
        self.sessions = sessions
        self.reason = reason
    }
}

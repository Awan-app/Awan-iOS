import Foundation

public struct AITaskSheetItem: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let task: AITask
    public let startTime: Date

    public var endTime: Date {
        startTime.addingTimeInterval(Double(task.estimatedDuration) * 60)
    }

    public init(task: AITask, startTime: Date = Date()) {
        self.id = task.id
        self.task = task
        self.startTime = startTime
    }
}

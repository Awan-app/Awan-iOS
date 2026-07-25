import Domain
import Foundation

/// Presentation-only wrapper that carries an `AITask` together with its
/// computed start time so the result sheet can derive the end time locally.
/// Does NOT mutate the Domain entity.
struct AITaskSheetItem: Identifiable {
    let id: UUID
    let task: AITask
    let startTime: Date

    var endTime: Date {
        startTime.addingTimeInterval(Double(task.estimatedDuration) * 60)
    }

    init(task: AITask, startTime: Date = Date()) {
        self.id = task.id
        self.task = task
        self.startTime = startTime
    }
}

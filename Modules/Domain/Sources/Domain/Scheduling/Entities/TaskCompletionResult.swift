import Foundation

public struct TaskCompletionResult: Sendable {
    public let task: AwanTask
    public let completedSessions: [Session]
    public let reward: CompletionReward

    public init(
        task: AwanTask,
        completedSessions: [Session],
        reward: CompletionReward
    ) {
        self.task = task
        self.completedSessions = completedSessions
        self.reward = reward
    }
}

public enum SetTaskCompletionResult: Sendable {
    case completed(TaskCompletionResult)
    case uncompleted(AwanTask)

    public var task: AwanTask {
        switch self {
        case .completed(let result):
            result.task
        case .uncompleted(let task):
            task
        }
    }
}

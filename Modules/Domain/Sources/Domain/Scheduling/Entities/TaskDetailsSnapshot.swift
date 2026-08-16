import Foundation

public struct TaskDetailsSnapshot: Equatable, Sendable {
    public let task: AwanTask
    public let sessions: [Session]
    public let goal: Goal?
    public let dependencies: [AwanTask]
    public let remainingRewardPoints: Int
    public let areAllSessionRewardsClaimed: Bool
    public let totalDurationMinutes: Int

    public init(
        task: AwanTask,
        sessions: [Session],
        goal: Goal?,
        dependencies: [AwanTask]
    ) {
        self.task = task
        self.sessions = sessions.sorted {
            if $0.timeRange.start != $1.timeRange.start {
                return $0.timeRange.start < $1.timeRange.start
            }
            return $0.id.uuidString < $1.id.uuidString
        }
        self.goal = goal
        self.dependencies = dependencies.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
        let rewardEligibleSessions = sessions.filter { $0.status != .cancelled }
        remainingRewardPoints = task.estimatedPoints * rewardEligibleSessions.filter {
            $0.firstCompletedAt == nil
        }.count
        areAllSessionRewardsClaimed = !rewardEligibleSessions.isEmpty
            && rewardEligibleSessions.allSatisfy { $0.firstCompletedAt != nil }
        totalDurationMinutes = sessions
            .filter { $0.status != .cancelled }
            .reduce(0) { $0 + $1.timeRange.durationMinutes }
    }
}

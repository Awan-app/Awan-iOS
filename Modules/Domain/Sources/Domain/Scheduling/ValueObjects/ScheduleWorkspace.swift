import Foundation

public struct ScheduleWorkspace: Hashable, Sendable {
    public let zones: [Zone]
    public let goals: [Goal]
    public let tasks: [AwanTask]
    public let sessions: [Session]

    public init(zones: [Zone], goals: [Goal], tasks: [AwanTask], sessions: [Session]) {
        self.zones = zones
        self.goals = goals
        self.tasks = tasks
        self.sessions = sessions
    }
}

public struct ScheduleOperationResult: Hashable, Sendable {
    public let workspace: ScheduleWorkspace
    public let nudge: ScheduleNudge?

    public init(workspace: ScheduleWorkspace, nudge: ScheduleNudge?) {
        self.workspace = workspace
        self.nudge = nudge
    }
}

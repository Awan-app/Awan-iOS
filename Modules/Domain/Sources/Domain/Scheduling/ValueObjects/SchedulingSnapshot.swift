import Foundation

public struct SchedulingSnapshot: Sendable {
    public let planningDay: Date
    public let timeZone: TimeZone
    public let zones: [Zone]
    public let goals: [Goal]
    public let tasks: [AwanTask]
    public let sessions: [Session]
    public let unavailableTime: [TimeRange]
    public let configuration: SchedulingConfiguration

    public init(
        planningDay: Date,
        timeZone: TimeZone,
        zones: [Zone],
        goals: [Goal],
        tasks: [AwanTask],
        sessions: [Session],
        unavailableTime: [TimeRange] = [],
        configuration: SchedulingConfiguration = .standard
    ) {
        self.planningDay = planningDay
        self.timeZone = timeZone
        self.zones = zones
        self.goals = goals
        self.tasks = tasks
        self.sessions = sessions
        self.unavailableTime = unavailableTime
        self.configuration = configuration
    }
}

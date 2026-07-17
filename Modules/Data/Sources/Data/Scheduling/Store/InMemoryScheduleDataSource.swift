import Domain
import Foundation

public actor InMemoryScheduleDataSource: LocalZoneDataSource {
    private var zones: [ZoneRecord]
    private var tasks: [AwanTask] = []
    private var goals: [Goal] = []
    private var sessions: [Session] = []

    public init(zones: [ZoneRecord] = FixedZoneDataSource.defaultRecords) {
        self.zones = zones
    }

    public func fetchZones() -> [ZoneRecord] { zones }

    public func updateZone(_ zone: ZoneRecord) {
        replace(zone, in: &zones)
    }

    public func resetZones() {
        zones = FixedZoneDataSource.defaultRecords
    }

    public func fetchTasks() -> [AwanTask] { tasks }

    public func addTask(_ task: AwanTask) {
        tasks.append(task)
    }

    public func updateTask(_ task: AwanTask) {
        replace(task, in: &tasks)
    }

    public func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
    }

    public func deleteAllTasks() {
        tasks.removeAll()
    }

    public func fetchGoals() -> [Goal] { goals }

    public func addGoal(_ goal: Goal) {
        goals.append(goal)
    }

    public func updateGoal(_ goal: Goal) {
        replace(goal, in: &goals)
    }

    public func deleteGoal(id: UUID) {
        goals.removeAll { $0.id == id }
    }

    public func deleteAllGoals() {
        goals.removeAll()
    }

    public func fetchSessions() -> [Session] { sessions }

    public func addSession(_ session: Session) {
        sessions.append(session)
    }

    public func updateSession(_ session: Session) {
        replace(session, in: &sessions)
    }

    public func deleteSession(id: UUID) {
        sessions.removeAll { $0.id == id }
    }

    public func deleteSessions(taskID: UUID) {
        sessions.removeAll { $0.taskID == taskID }
    }

    public func deleteAllSessions() {
        sessions.removeAll()
    }

    private func replace<Value: Identifiable>(_ value: Value, in values: inout [Value])
    where Value.ID: Equatable {
        if let index = values.firstIndex(where: { $0.id == value.id }) {
            values[index] = value
        } else {
            values.append(value)
        }
    }
}

import Domain
import Foundation

public actor InMemoryScheduleDataSource: LocalZoneDataSource, LocalTaskDataSource, LocalSessionDataSource, LocalGoalDataSource, LocalTemplateDataSource, LocalTemplateOverrideDataSource {
    private var zones: [ZoneRecord]
    private var tasks: [TaskRecord] = []
    private var goals: [GoalRecord] = []
    private var sessions: [SessionRecord] = []
    private var templates: [TemplateRecord] = []
    private var templateOverrides: [TemplateOverrideRecord] = []

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

    public func fetchTasks() async throws -> [TaskRecord] { tasks }
    public func fetchTask(id: UUID) async throws -> AwanTask? {
        try tasks.first { $0.id == id }?.toDomain()
    }
    public func addTask(_ task: TaskRecord) async throws { tasks.append(task) }
    public func updateTask(_ task: TaskRecord) async throws { replace(task, in: &tasks) }
    public func deleteTask(id: UUID) async throws { tasks.removeAll { $0.id == id } }
    public func deleteAllTasks() async throws { tasks.removeAll() }

    public func addDependency(taskID: UUID, dependsOnID: UUID) async throws {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        let record = tasks[index]
        var deps = Set(record.dependencyIDs)
        deps.insert(dependsOnID)
        let updated = TaskRecord(
            id: record.id, title: record.title, description: record.description,
            statusRaw: record.statusRaw, goalID: record.goalID, zoneID: record.zoneID,
            estimatedDurationMinutes: record.estimatedDurationMinutes,
            allowTaskSplitting: record.allowTaskSplitting, mandatory: record.mandatory,
            estimatedPoints: record.estimatedPoints, dependencyIDs: Array(deps).sorted(),
            order: record.order
        )
        tasks[index] = updated
    }

    public func removeDependency(taskID: UUID, dependsOnID: UUID) async throws {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        let record = tasks[index]
        var deps = Set(record.dependencyIDs)
        deps.remove(dependsOnID)
        let updated = TaskRecord(
            id: record.id, title: record.title, description: record.description,
            statusRaw: record.statusRaw, goalID: record.goalID, zoneID: record.zoneID,
            estimatedDurationMinutes: record.estimatedDurationMinutes,
            allowTaskSplitting: record.allowTaskSplitting, mandatory: record.mandatory,
            estimatedPoints: record.estimatedPoints, dependencyIDs: Array(deps).sorted(),
            order: record.order
        )
        tasks[index] = updated
    }

    public func fetchDependencies(taskID: UUID) async throws -> [AwanTask] {
        guard let record = tasks.first(where: { $0.id == taskID }) else { return [] }
        return try tasks.filter { record.dependencyIDs.contains($0.id) }.map { try $0.toDomain() }
    }

    public func fetchDependents(taskID: UUID) async throws -> [AwanTask] {
        try tasks.filter { $0.dependencyIDs.contains(taskID) }.map { try $0.toDomain() }
    }

    public func moveTask(id: UUID, toGoalID: UUID?, toZoneID: UUID?, newOrder: Int) async throws {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        let record = tasks[index]
        let updated = TaskRecord(
            id: record.id, title: record.title, description: record.description,
            statusRaw: record.statusRaw, goalID: toGoalID, zoneID: toZoneID,
            estimatedDurationMinutes: record.estimatedDurationMinutes,
            allowTaskSplitting: record.allowTaskSplitting, mandatory: record.mandatory,
            estimatedPoints: record.estimatedPoints, dependencyIDs: record.dependencyIDs,
            order: newOrder
        )
        tasks[index] = updated
        
        var siblings = tasks.filter { $0.goalID == toGoalID && $0.zoneID == toZoneID && $0.id != id }
        siblings.sort { $0.order < $1.order }
        
        var currentOrder = 0
        for i in 0..<siblings.count {
            if currentOrder == newOrder {
                currentOrder += 1
            }
            let sibling = siblings[i]
            if sibling.order != currentOrder {
                if let siblingIndex = tasks.firstIndex(where: { $0.id == sibling.id }) {
                    tasks[siblingIndex] = TaskRecord(
                        id: sibling.id, title: sibling.title, description: sibling.description,
                        statusRaw: sibling.statusRaw, goalID: sibling.goalID, zoneID: sibling.zoneID,
                        estimatedDurationMinutes: sibling.estimatedDurationMinutes,
                        allowTaskSplitting: sibling.allowTaskSplitting, mandatory: sibling.mandatory,
                        estimatedPoints: sibling.estimatedPoints, dependencyIDs: sibling.dependencyIDs,
                        order: currentOrder
                    )
                }
            }
            currentOrder += 1
        }
    }
    public func fetchGoals() async throws -> [GoalRecord] { goals }
    public func fetchGoal(id: UUID) async throws -> Goal? {
        try goals.first { $0.id == id }?.toDomain()
    }
    public func fetchInboxTasks() async throws -> [AwanTask] {
        try tasks.filter { $0.goalID == nil }.map { try $0.toDomain() }
    }
    public func fetchTasks(goalID: UUID) async throws -> [AwanTask] {
        try tasks.filter { $0.goalID == goalID }.map { try $0.toDomain() }
    }
    public func addGoal(_ goal: GoalRecord) async throws { goals.append(goal) }
    public func updateGoal(_ goal: GoalRecord) async throws { replace(goal, in: &goals) }
    public func deleteGoal(id: UUID) async throws { goals.removeAll { $0.id == id } }
    public func deleteAllGoals() async throws { goals.removeAll() }
    public func addTasks(_ newTasks: [AwanTask]) async throws {
        for task in newTasks {
            tasks.append(TaskRecord(domain: task))
        }
    }

    public func fetchSessions() async throws -> [SessionRecord] { sessions }
    public func addSession(_ session: SessionRecord) async throws { sessions.append(session) }
    public func updateSession(_ session: SessionRecord) async throws { replace(session, in: &sessions) }
    public func deleteSession(id: UUID) async throws { sessions.removeAll { $0.id == id } }
    public func deleteSessions(taskID: UUID) async throws { sessions.removeAll { $0.taskID == taskID } }
    public func deleteAllSessions() async throws { sessions.removeAll() }

    public func fetchTemplates() async throws -> [Template] { templates.map { $0.toDomain() } }
    public func addTemplate(_ template: Template) async throws { templates.append(TemplateRecord(domain: template)) }
    public func updateTemplate(_ template: Template) async throws { replace(TemplateRecord(domain: template), in: &templates) }
    public func deleteTemplate(id: UUID) async throws { templates.removeAll { $0.id == id } }
    public func deleteAllTemplates() async throws { templates.removeAll() }

    public func fetchTemplateOverrides() async throws -> [TemplateOverride] { templateOverrides.map { $0.toDomain() } }
    public func addTemplateOverride(_ templateOverride: TemplateOverride) async throws { templateOverrides.append(TemplateOverrideRecord(domain: templateOverride)) }
    public func updateTemplateOverride(_ templateOverride: TemplateOverride) async throws { replace(TemplateOverrideRecord(domain: templateOverride), in: &templateOverrides) }
    public func deleteTemplateOverride(id: UUID) async throws { templateOverrides.removeAll { $0.id == id } }
    public func deleteAllTemplateOverrides() async throws { templateOverrides.removeAll() }

    private func replace<Value: Identifiable>(_ value: Value, in values: inout [Value])
    where Value.ID: Equatable {
        if let index = values.firstIndex(where: { $0.id == value.id }) {
            values[index] = value
        } else {
            values.append(value)
        }
    }
}

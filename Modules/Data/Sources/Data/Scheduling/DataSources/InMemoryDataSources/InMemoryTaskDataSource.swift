import Domain
import Foundation

public actor InMemoryTaskDataSource: LocalTaskDataSource {
    private var tasksByID: [UUID: AwanTask]

    public init(tasks: [AwanTask] = []) {
        tasksByID = tasks.reduce(into: [:]) { $0[$1.id] = $1 }
    }

    public func fetchTasks() -> [AwanTask] {
        Array(tasksByID.values)
    }

    public func fetchTask(id: UUID) -> AwanTask? {
        tasksByID[id]
    }

    public func addTask(_ task: AwanTask) throws {
        guard tasksByID[task.id] == nil else {
            throw SchedulingPersistenceError.duplicateID(task.id)
        }
        tasksByID[task.id] = task
    }

    public func updateTask(_ task: AwanTask) throws {
        guard tasksByID[task.id] != nil else {
            throw SchedulingError.entityNotFound(id: task.id)
        }
        tasksByID[task.id] = task
    }

    public func deleteTask(id: UUID) {
        tasksByID[id] = nil
    }

    public func deleteAllTasks() {
        tasksByID.removeAll()
    }

    public func addDependency(taskID: UUID, dependsOnID: UUID) throws {
        guard let task = tasksByID[taskID] else {
            throw SchedulingError.entityNotFound(id: taskID)
        }
        guard tasksByID[dependsOnID] != nil else {
            throw SchedulingError.missingDependency(taskID: taskID, dependencyID: dependsOnID)
        }
        var dependencyIDs = task.dependencyIDs
        guard dependencyIDs.insert(dependsOnID).inserted else { return }
        tasksByID[taskID] = copy(task, dependencyIDs: dependencyIDs)
    }

    public func removeDependency(taskID: UUID, dependsOnID: UUID) throws {
        guard let task = tasksByID[taskID] else {
            throw SchedulingError.entityNotFound(id: taskID)
        }
        var dependencyIDs = task.dependencyIDs
        guard dependencyIDs.remove(dependsOnID) != nil else { return }
        tasksByID[taskID] = copy(task, dependencyIDs: dependencyIDs)
    }

    public func fetchDependencies(taskID: UUID) throws -> [AwanTask] {
        guard let task = tasksByID[taskID] else {
            throw SchedulingError.entityNotFound(id: taskID)
        }
        return try task.dependencyIDs.map { dependencyID in
            guard let dependency = tasksByID[dependencyID] else {
                throw SchedulingError.missingDependency(
                    taskID: taskID,
                    dependencyID: dependencyID
                )
            }
            return dependency
        }
    }

    public func fetchDependents(taskID: UUID) throws -> [AwanTask] {
        guard tasksByID[taskID] != nil else {
            throw SchedulingError.entityNotFound(id: taskID)
        }
        return tasksByID.values.filter { $0.dependencyIDs.contains(taskID) }
    }

    private func copy(_ task: AwanTask, dependencyIDs: Set<UUID>) -> AwanTask {
        AwanTask(
            id: task.id,
            title: task.title,
            description: task.description,
            status: task.status,
            goalID: task.goalID,
            zoneID: task.zoneID,
            duration: task.duration,
            isSplittable: task.isSplittable,
            mandatory: task.mandatory,
            estimatedPoints: task.estimatedPoints,
            dependencyIDs: dependencyIDs
        )
    }
}

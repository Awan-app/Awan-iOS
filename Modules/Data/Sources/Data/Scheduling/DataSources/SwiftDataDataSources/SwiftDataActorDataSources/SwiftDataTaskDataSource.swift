import Domain
import Foundation
import SwiftData

@ModelActor
public actor SwiftDataTaskDataSource: LocalTaskDataSource {
    public func fetchTasks() throws -> [AwanTask] {
        try modelContext.fetch(FetchDescriptor<TaskModel>()).map { try $0.toDomain() }
    }

    public func fetchTask(id: UUID) throws -> AwanTask? {
        try find(id: id)?.toDomain()
    }

    public func addTask(_ task: AwanTask) throws {
        guard try find(id: task.id) == nil else {
            throw SchedulingPersistenceError.duplicateID(task.id)
        }
        modelContext.insert(TaskModel(domain: task))
        try modelContext.save()
    }

    public func updateTask(_ task: AwanTask) throws {
        guard let model = try find(id: task.id) else {
            throw SchedulingError.entityNotFound(id: task.id)
        }
        model.update(from: task)
        try modelContext.save()
    }

    public func deleteTask(id: UUID) throws {
        guard let model = try find(id: id) else { return }
        modelContext.delete(model)
        try modelContext.save()
    }

    public func deleteAllTasks() throws {
        for model in try modelContext.fetch(FetchDescriptor<TaskModel>()) {
            modelContext.delete(model)
        }
        try modelContext.save()
    }

    public func addDependency(taskID: UUID, dependsOnID: UUID) throws {
        guard let task = try find(id: taskID) else {
            throw SchedulingError.entityNotFound(id: taskID)
        }
        guard try find(id: dependsOnID) != nil else {
            throw SchedulingError.missingDependency(
                taskID: taskID,
                dependencyID: dependsOnID
            )
        }
        var dependencyIDs = Set(task.dependencyIDs)
        guard dependencyIDs.insert(dependsOnID).inserted else { return }
        task.dependencyIDs = dependencyIDs.sorted()
        try modelContext.save()
    }

    public func removeDependency(taskID: UUID, dependsOnID: UUID) throws {
        guard let task = try find(id: taskID) else {
            throw SchedulingError.entityNotFound(id: taskID)
        }
        var dependencyIDs = Set(task.dependencyIDs)
        guard dependencyIDs.remove(dependsOnID) != nil else { return }
        task.dependencyIDs = dependencyIDs.sorted()
        try modelContext.save()
    }

    public func fetchDependencies(taskID: UUID) throws -> [AwanTask] {
        guard let task = try find(id: taskID) else {
            throw SchedulingError.entityNotFound(id: taskID)
        }
        let modelsByID = Dictionary(
            uniqueKeysWithValues: try modelContext.fetch(FetchDescriptor<TaskModel>())
                .map { ($0.id, $0) }
        )
        return try task.dependencyIDs.map { dependencyID in
            guard let dependency = modelsByID[dependencyID] else {
                throw SchedulingError.missingDependency(
                    taskID: taskID,
                    dependencyID: dependencyID
                )
            }
            return try dependency.toDomain()
        }
    }

    public func fetchDependents(taskID: UUID) throws -> [AwanTask] {
        guard try find(id: taskID) != nil else {
            throw SchedulingError.entityNotFound(id: taskID)
        }
        return try modelContext.fetch(FetchDescriptor<TaskModel>())
            .filter { $0.dependencyIDs.contains(taskID) }
            .map { try $0.toDomain() }
    }

    private func find(id: UUID) throws -> TaskModel? {
        let targetID = id
        var descriptor = FetchDescriptor<TaskModel>(
            predicate: #Predicate { $0.id == targetID }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}

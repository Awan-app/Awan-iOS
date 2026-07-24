import Combine
import Domain
import Foundation
import SwiftData

@ModelActor
public actor SwiftDataTaskDataSource: LocalTaskDataSource {
    private let changes = LocalDataObservationHub()

    public nonisolated func observeTasks() -> AnyPublisher<[AwanTask], Error> {
        changes.publisher()
            .prepend(())
            .flatMap(maxPublishers: .max(1)) { [self] _ in
                AsyncValuePublisher.make { try await self.fetchTasks() }
            }
            .eraseToAnyPublisher()
    }

    public func fetchTasks() throws -> [AwanTask] {
        try modelContext.fetch(FetchDescriptor<TaskModel>()).map { try $0.toDomain() }
    }

    public func fetchTask(id: UUID) throws -> AwanTask? {
        try find(id: id)?.toDomain()
    }

    public func replaceTasks(_ tasks: [AwanTask]) throws {
        let existing = try modelContext.fetch(FetchDescriptor<TaskModel>())
        let desiredIDs = Set(tasks.map(\.id))
        let existingByID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

        for model in existing where !desiredIDs.contains(model.id) {
            modelContext.delete(model)
        }
        for task in tasks {
            if let model = existingByID[task.id] {
                model.update(from: task)
            } else {
                modelContext.insert(TaskModel(domain: task))
            }
        }
        try modelContext.save()
        changes.send()
    }

    public func upsertTasks(_ tasks: [AwanTask]) throws {
        let existing = try modelContext.fetch(FetchDescriptor<TaskModel>())
        let existingByID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
        for task in tasks {
            if let model = existingByID[task.id] {
                model.update(from: task)
            } else {
                modelContext.insert(TaskModel(domain: task))
            }
        }
        try modelContext.save()
        changes.send()
    }

    public func addTask(_ task: AwanTask) throws {
        guard try find(id: task.id) == nil else {
            throw SchedulingPersistenceError.duplicateID(task.id)
        }
        modelContext.insert(TaskModel(domain: task))
        try modelContext.save()
        changes.send()
    }

    public func updateTask(_ task: AwanTask) throws {
        guard let model = try find(id: task.id) else {
            throw SchedulingError.entityNotFound(id: task.id)
        }
        model.update(from: task)
        try modelContext.save()
        changes.send()
    }

    public func deleteTask(id: UUID) throws {
        guard let model = try find(id: id) else { return }
        modelContext.delete(model)
        try modelContext.save()
        changes.send()
    }

    public func deleteAllTasks() throws {
        for model in try modelContext.fetch(FetchDescriptor<TaskModel>()) {
            modelContext.delete(model)
        }
        try modelContext.save()
        changes.send()
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
        changes.send()
    }

    public func removeDependency(taskID: UUID, dependsOnID: UUID) throws {
        guard let task = try find(id: taskID) else {
            throw SchedulingError.entityNotFound(id: taskID)
        }
        var dependencyIDs = Set(task.dependencyIDs)
        guard dependencyIDs.remove(dependsOnID) != nil else { return }
        task.dependencyIDs = dependencyIDs.sorted()
        try modelContext.save()
        changes.send()
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

import Combine
import Domain
import Foundation
import SwiftData

@ModelActor
public actor SwiftDataGoalDataSource: LocalGoalDataSource {
    private let changes = LocalDataObservationHub()

    public nonisolated func observeGoals() -> AnyPublisher<[Goal], Error> {
        changes.publisher()
            .prepend(())
            .flatMap(maxPublishers: .max(1)) { [self] _ in
                AsyncValuePublisher.make { try await self.fetchGoals() }
            }
            .eraseToAnyPublisher()
    }

    public func fetchGoals() throws -> [Goal] {
        try modelContext.fetch(FetchDescriptor<GoalModel>()).map { try $0.toDomain() }
    }

    public func fetchGoal(id: UUID) throws -> Goal? {
        try find(id: id)?.toDomain()
    }

    public func addGoal(_ goal: Goal) throws {
        guard try find(id: goal.id) == nil else {
            throw SchedulingPersistenceError.duplicateID(goal.id)
        }
        modelContext.insert(GoalModel(domain: goal))
        try modelContext.save()
        changes.send()
    }

    public func updateGoal(_ goal: Goal) throws {
        guard let model = try find(id: goal.id) else {
            throw SchedulingError.entityNotFound(id: goal.id)
        }
        model.update(from: goal)
        try modelContext.save()
        changes.send()
    }

    public func replaceActiveGoals(_ goals: [Goal]) throws {
        let incomingIDs = Set(goals.map(\.id))
        let existing = try modelContext.fetch(FetchDescriptor<GoalModel>())

        for model in existing
        where model.statusRaw == GoalStatus.active.rawValue
            || incomingIDs.contains(model.id) {
            modelContext.delete(model)
        }
        for goal in goals {
            modelContext.insert(GoalModel(domain: goal))
        }
        try modelContext.save()
        changes.send()
    }

    public func deleteGoal(id: UUID) throws {
        guard let model = try find(id: id) else { return }
        modelContext.delete(model)
        try modelContext.save()
        changes.send()
    }

    public func deleteAllGoals() throws {
        for model in try modelContext.fetch(FetchDescriptor<GoalModel>()) {
            modelContext.delete(model)
        }
        try modelContext.save()
        changes.send()
    }

    private func find(id: UUID) throws -> GoalModel? {
        let targetID = id
        var descriptor = FetchDescriptor<GoalModel>(
            predicate: #Predicate { $0.id == targetID }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}

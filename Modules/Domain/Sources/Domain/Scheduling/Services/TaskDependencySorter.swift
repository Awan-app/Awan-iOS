import Foundation

public protocol TaskDependencyOrdering: Sendable {
    func order(_ tasks: [AwanTask]) throws -> [AwanTask]
}

public struct StableTaskDependencySorter: TaskDependencyOrdering {
    public init() {}

    public func order(_ tasks: [AwanTask]) throws -> [AwanTask] {
        let tasksByID = Dictionary(grouping: tasks, by: \.id)
        if let duplicate = tasksByID.first(where: { $0.value.count > 1 })?.key {
            throw SchedulingError.duplicateTaskID(duplicate)
        }

        let knownIDs = Set(tasksByID.keys)
        for task in tasks {
            if let missing = task.dependencyIDs.first(where: { !knownIDs.contains($0) }) {
                throw SchedulingError.missingDependency(taskID: task.id, dependencyID: missing)
            }
        }

        var remainingDependencyCount = Dictionary(
            uniqueKeysWithValues: tasks.map { ($0.id, $0.dependencyIDs.count) }
        )
        var dependents: [UUID: [UUID]] = [:]
        for task in tasks {
            for dependencyID in task.dependencyIDs {
                dependents[dependencyID, default: []].append(task.id)
            }
        }

        var eligible = tasks
            .filter { $0.dependencyIDs.isEmpty }
            .sorted(by: stableOrder)
        var ordered: [AwanTask] = []

        while !eligible.isEmpty {
            let task = eligible.removeFirst()
            ordered.append(task)

            for dependentID in dependents[task.id, default: []].sorted(by: uuidOrder) {
                let count = (remainingDependencyCount[dependentID] ?? 0) - 1
                remainingDependencyCount[dependentID] = count
                if count == 0, let dependent = tasksByID[dependentID]?.first {
                    eligible.append(dependent)
                    eligible.sort(by: stableOrder)
                }
            }
        }

        guard ordered.count == tasks.count else {
            let orderedIDs = Set(ordered.map(\.id))
            throw SchedulingError.dependencyCycle(taskIDs: knownIDs.subtracting(orderedIDs))
        }

        return ordered
    }

    private func stableOrder(_ lhs: AwanTask, _ rhs: AwanTask) -> Bool {
        uuidOrder(lhs.id, rhs.id)
    }

    private func uuidOrder(_ lhs: UUID, _ rhs: UUID) -> Bool {
        lhs.uuidString < rhs.uuidString
    }
}

import Foundation

public protocol FetchTaskDetailsUseCase: Sendable {
    func execute(taskID: UUID) async throws -> TaskDetailsSnapshot
}

public struct DefaultFetchTaskDetailsUseCase: FetchTaskDetailsUseCase {
    private let taskRepository: any TaskRepository
    private let sessionRepository: any SessionRepository
    private let goalRepository: any GoalRepository

    public init(
        taskRepository: any TaskRepository,
        sessionRepository: any SessionRepository,
        goalRepository: any GoalRepository
    ) {
        self.taskRepository = taskRepository
        self.sessionRepository = sessionRepository
        self.goalRepository = goalRepository
    }

    public func execute(taskID: UUID) async throws -> TaskDetailsSnapshot {
        async let taskResult = taskRepository.refreshTask(id: taskID)
        async let sessionsResult = sessionRepository.fetchSessions(taskID: taskID)
        async let goalsResult = goalRepository.fetchGoals()
        async let dependenciesResult = taskRepository.fetchDependencies(taskID: taskID)

        let (task, sessions, goals, dependencies) = try await (
            taskResult,
            sessionsResult,
            goalsResult,
            dependenciesResult
        )
        return TaskDetailsSnapshot(
            task: task,
            sessions: sessions,
            goal: goals.first { $0.id == task.goalID },
            dependencies: dependencies
        )
    }
}

public struct EditTaskDetailsRequest: Equatable, Sendable {
    public let taskID: UUID
    public let title: String
    public let description: String?
    public let mandatory: Bool
    public let isSplittable: Bool
    public let category: TaskCategory?

    public init(
        taskID: UUID,
        title: String,
        description: String?,
        mandatory: Bool,
        isSplittable: Bool,
        category: TaskCategory?
    ) {
        self.taskID = taskID
        self.title = title
        self.description = description
        self.mandatory = mandatory
        self.isSplittable = isSplittable
        self.category = category
    }
}

public protocol EditTaskDetailsUseCase: Sendable {
    func execute(_ request: EditTaskDetailsRequest) async throws -> AwanTask
}

public struct DefaultEditTaskDetailsUseCase: EditTaskDetailsUseCase {
    private let repository: any TaskRepository

    public init(repository: any TaskRepository) {
        self.repository = repository
    }

    public func execute(_ request: EditTaskDetailsRequest) async throws -> AwanTask {
        let title = request.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw SchedulingError.invalidConfiguration }
        let existing = try await repository.refreshTask(id: request.taskID)
        let description = request.description?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let updated = AwanTask(
            id: existing.id,
            title: title,
            description: description?.isEmpty == true ? nil : description,
            status: existing.status,
            completedAt: existing.completedAt,
            goalID: existing.goalID,
            duration: existing.duration,
            isSplittable: request.isSplittable,
            mandatory: request.mandatory,
            estimatedPoints: existing.estimatedPoints,
            dependencyIDs: existing.dependencyIDs,
            category: request.category
        )
        try await repository.updateTask(updated)
        return try await repository.refreshTask(id: request.taskID)
    }
}

public protocol FetchTaskDependencyCandidatesUseCase: Sendable {
    func execute(task: AwanTask) async throws -> [AwanTask]
}

public struct DefaultFetchTaskDependencyCandidatesUseCase: FetchTaskDependencyCandidatesUseCase {
    private let taskRepository: any TaskRepository
    private let goalRepository: any GoalRepository

    public init(
        taskRepository: any TaskRepository,
        goalRepository: any GoalRepository
    ) {
        self.taskRepository = taskRepository
        self.goalRepository = goalRepository
    }

    public func execute(task current: AwanTask) async throws -> [AwanTask] {
        let goalTasks: [AwanTask]
        if let goalID = current.goalID {
            goalTasks = try await goalRepository.fetchGoalTasks(goalID: goalID)
        } else {
            goalTasks = try await taskRepository.fetchInboxTasks()
        }
        let allTasks = Dictionary(
            goalTasks.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        return allTasks.values
            .filter { candidate in
                candidate.id != current.id
                    && !current.dependencyIDs.contains(candidate.id)
                    && candidate.status != .cancelled
                    && !Self.depends(
                        candidate.id,
                        on: current.id,
                        tasksByID: allTasks
                    )
            }
            .sorted {
                let comparison = $0.title.localizedCaseInsensitiveCompare($1.title)
                return comparison == .orderedSame
                    ? $0.id.uuidString < $1.id.uuidString
                    : comparison == .orderedAscending
            }
    }

    private static func depends(
        _ candidateID: UUID,
        on targetID: UUID,
        tasksByID: [UUID: AwanTask]
    ) -> Bool {
        var pending = [candidateID]
        var visited: Set<UUID> = []
        while let taskID = pending.popLast() {
            guard visited.insert(taskID).inserted,
                  let task = tasksByID[taskID] else { continue }
            if task.dependencyIDs.contains(targetID) { return true }
            pending.append(contentsOf: task.dependencyIDs)
        }
        return false
    }
}

public protocol AddTaskDependencyUseCase: Sendable {
    func execute(task: AwanTask, dependency: AwanTask) async throws
}

public struct DefaultAddTaskDependencyUseCase: AddTaskDependencyUseCase {
    private let repository: any TaskRepository

    public init(repository: any TaskRepository) { self.repository = repository }

    public func execute(task: AwanTask, dependency: AwanTask) async throws {
        guard task.goalID == dependency.goalID else {
            throw SchedulingError.invalidConfiguration
        }
        try await repository.addDependency(
            taskID: task.id,
            dependsOnID: dependency.id
        )
    }
}

public protocol RemoveTaskDependencyUseCase: Sendable {
    func execute(taskID: UUID, dependencyID: UUID) async throws
}

public struct DefaultRemoveTaskDependencyUseCase: RemoveTaskDependencyUseCase {
    private let repository: any TaskRepository

    public init(repository: any TaskRepository) { self.repository = repository }

    public func execute(taskID: UUID, dependencyID: UUID) async throws {
        try await repository.removeDependency(taskID: taskID, dependsOnID: dependencyID)
    }
}

public protocol RemoveTaskFromGoalUseCase: Sendable {
    func execute(_ task: AwanTask) async throws -> AwanTask
}

public struct DefaultRemoveTaskFromGoalUseCase: RemoveTaskFromGoalUseCase {
    private let repository: any GoalRepository

    public init(repository: any GoalRepository) { self.repository = repository }

    public func execute(_ task: AwanTask) async throws -> AwanTask {
        try await repository.moveTaskToInbox(task)
    }
}

public protocol DeleteTaskDetailsUseCase: Sendable {
    func execute(taskID: UUID) async throws
}

public struct DefaultDeleteTaskDetailsUseCase: DeleteTaskDetailsUseCase {
    private let repository: any TaskRepository

    public init(repository: any TaskRepository) { self.repository = repository }

    public func execute(taskID: UUID) async throws {
        try await repository.deleteTask(id: taskID)
    }
}

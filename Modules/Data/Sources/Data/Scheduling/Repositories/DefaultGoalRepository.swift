import Combine
import Domain
import Foundation

public struct DefaultGoalRepository: GoalRepository {
    private let localDataSource: any LocalGoalDataSource
    private let remoteDataSource: any RemoteGoalDataSource
    private let remoteTaskDataSource: any RemoteTaskDataSource
    private let localTaskDataSource: (any LocalTaskDataSource)?

    public init(
        localDataSource: any LocalGoalDataSource,
        remoteDataSource: any RemoteGoalDataSource,
        remoteTaskDataSource: any RemoteTaskDataSource,
        localTaskDataSource: (any LocalTaskDataSource)? = nil
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
        self.remoteTaskDataSource = remoteTaskDataSource
        self.localTaskDataSource = localTaskDataSource
    }

    public func fetchGoals() async throws -> [Goal] {
        try await loadRemoteGoals()
    }

    public func fetchGoalTasks(goalID: UUID) async throws -> [AwanTask] {
        let dtos = try await remoteDataSource.getGoalTasks(goalId: goalID)
        let tasks = try dtos.map { try HomeRemoteMapper.task($0, defaultDuration: 30) }
        try await localTaskDataSource?.upsertTasks(tasks)
        return tasks
    }

    public func observeGoals() -> AnyPublisher<[Goal], Error> {
        let cached = localDataSource.observeGoals()
            .map(Self.activeGoalPage)
            .catch { _ in Empty<[Goal], Error>() }
            .eraseToAnyPublisher()
        let remote = AsyncValuePublisher.make { try await loadRemoteGoals() }
            .catch { _ in Empty<[Goal], Error>() }
            .eraseToAnyPublisher()

        return cached
            .merge(with: remote)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private func loadRemoteGoals() async throws -> [Goal] {
        let response = try await remoteDataSource.listGoals(
            parameters: ListGoalsParameters(
                status: "ACTIVE",
                includeInbox: false,
                expand: false,
                page: 0,
                size: 20,
                sort: "createdAt,desc"
            )
        )
        let goals = try response.content.map(HomeRemoteMapper.goal)
        let page = Self.activeGoalPage(goals)
        try await localDataSource.replaceActiveGoals(page)
        return page
    }

    private static func activeGoalPage(_ goals: [Goal]) -> [Goal] {
        goals
            .filter { $0.status == .active }
            .sorted {
                if $0.createdAt != $1.createdAt {
                    return $0.createdAt > $1.createdAt
                }
                return $0.id.uuidString < $1.id.uuidString
            }
            .prefix(20)
            .map { $0 }
    }

    public func addGoal(_ goal: Goal) async throws {
        try await localDataSource.addGoal(goal)
    }

    public func createGoal(
        title: String,
        description: String?,
        targetDate: Date?
    ) async throws -> Goal {
        let dateString = targetDate.map { LocalDateKey.value(for: $0) }
        let requestDTO = CreateGoalRequestDTO(
            title: title,
            description: description,
            targetDate: dateString,
            tasks: []
        )
        let responseDTO = try await remoteDataSource.createGoal(requestDTO)
        let goal = try HomeRemoteMapper.goal(responseDTO)
        try await localDataSource.addGoal(goal)
        return goal
    }

    public func addTaskToGoal(goalID: UUID, task: AwanTask) async throws -> AwanTask {
        let requestDTO = MoveTaskRequestDTO(goalID: goalID)
        let response = try await remoteTaskDataSource.moveTask(
            taskID: task.id,
            request: requestDTO
        )
        let accepted = try HomeRemoteMapper.task(
            response,
            defaultDuration: task.duration.minutes
        )
        let updatedTask = AwanTask(
            id: accepted.id,
            title: accepted.title,
            description: accepted.description,
            status: accepted.status,
            completedAt: accepted.completedAt,
            goalID: goalID,
            duration: accepted.duration,
            isSplittable: accepted.isSplittable,
            mandatory: accepted.mandatory,
            estimatedPoints: accepted.estimatedPoints,
            dependencyIDs: accepted.dependencyIDs,
            category: accepted.category
        )
        try await localTaskDataSource?.upsertTasks([updatedTask])
        return updatedTask
    }

    public func moveTaskToInbox(_ task: AwanTask) async throws -> AwanTask {
        let inbox = try await remoteDataSource.getInbox()
        let response = try await remoteTaskDataSource.moveTask(
            taskID: task.id,
            request: MoveTaskRequestDTO(goalID: inbox.id)
        )
        let mapped = try HomeRemoteMapper.task(
            response,
            defaultDuration: task.duration.minutes
        )
        let accepted = AwanTask(
            id: mapped.id,
            title: mapped.title,
            description: mapped.description,
            status: mapped.status,
            completedAt: mapped.completedAt,
            goalID: inbox.id,
            duration: mapped.duration,
            isSplittable: mapped.isSplittable,
            mandatory: mapped.mandatory,
            estimatedPoints: mapped.estimatedPoints,
            dependencyIDs: mapped.dependencyIDs,
            category: mapped.category
        )
        try await localTaskDataSource?.upsertTasks([accepted])
        return accepted
    }


    public func updateGoal(_ goal: Goal) async throws {
        let dateString = goal.deadline.map { LocalDateKey.value(for: $0) }
        let requestDTO = UpdateGoalRequestDTO(
            title: goal.name,
            description: goal.description,
            status: nil,
            targetDate: dateString
        )
        let responseDTO = try await remoteDataSource.updateGoal(goalId: goal.id, request: requestDTO)
        let mappedGoal = try HomeRemoteMapper.goal(responseDTO)
        // Always trust `goal.deadline` (the user's intent) over whatever
        // the server echoes back, because some PATCH backends silently
        // ignore null for optional fields.
        let finalGoal = Goal(
            id: mappedGoal.id,
            name: mappedGoal.name,
            description: mappedGoal.description,
            status: mappedGoal.status,
            deadline: goal.deadline,
            createdAt: mappedGoal.createdAt
        )
        try await localDataSource.updateGoal(finalGoal)
    }

    public func deleteGoal(id: UUID) async throws {
        try await remoteDataSource.deleteGoal(goalId: id)
        try await localDataSource.deleteGoal(id: id)
    }
    public func deleteAllGoals() async throws {
        try await localDataSource.deleteAllGoals()
    }
}

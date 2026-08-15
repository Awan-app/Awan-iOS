//
//  GoalsViewModel.swift
//  Presentation
//

import Combine
import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class GoalsViewModel {
    public var state: GoalsState
    public var onSelectGoal: ((UUID) -> Void)?

    @ObservationIgnored private let useCases: GoalsUseCases
    @ObservationIgnored private let mapper: GoalsStateMapper
    @ObservationIgnored private var cancellable: AnyCancellable?

    public init(
        useCases: GoalsUseCases,
        mapper: GoalsStateMapper = GoalsStateMapper(),
        onSelectGoal: ((UUID) -> Void)? = nil
    ) {
        self.useCases = useCases
        self.mapper = mapper
        self.onSelectGoal = onSelectGoal
        self.state = GoalsState()
    }

    public func send(_ action: GoalsAction) {
        switch action {
        case .appeared, .refresh:
            load()
        case let .searchQueryChanged(query):
            state.searchQuery = query
        case let .selectGoal(id):
            onSelectGoal?(id)
        case let .loadGoalTasks(goalID):
            loadGoalTasks(goalID: goalID)
        case let .createGoal(title, description, targetDate):
            createGoal(title: title, description: description, targetDate: targetDate)
        case .showCreateGoalSheet:
            state.isCreateGoalSheetPresented = true
        case .dismissCreateGoalSheet:
            state.isCreateGoalSheetPresented = false
        case .dismissError:
            state.failureMessage = nil
            state.goalTasksFailureMessage = nil
        case let .showAddTaskSheet(goalID):
            state.addTaskSheetGoalID = goalID
            loadInboxTasksForSheet()
        case .dismissAddTaskSheet:
            state.addTaskSheetGoalID = nil
            state.inboxTasksForSheet = []
        case let .addInboxTaskToGoal(task, goalID):
            addInboxTaskToGoal(task: task, goalID: goalID)
        case .dismissAddTaskError:
            state.addTaskFailureMessage = nil
        }
    }

    private func createGoal(title: String, description: String?, targetDate: Date?) {
        guard let createEmptyGoal = useCases.createEmptyGoal else { return }
        state.isCreatingGoal = true
        state.isCreateGoalSheetPresented = false

        Task { [weak self] in
            do {
                _ = try await createEmptyGoal.execute(title: title, description: description, targetDate: targetDate)
                guard let self else { return }
                self.state.isCreatingGoal = false
                self.load()
            } catch {
                guard let self else { return }
                self.state.isCreatingGoal = false
                self.state.failureMessage = error.localizedDescription
            }
        }
    }

    private func loadInboxTasksForSheet() {
        guard let fetchInboxTasks = useCases.fetchInboxTasks else { return }
        state.isLoadingInboxTasks = true
        state.inboxTasksForSheet = []
        Task { [weak self] in
            do {
                let inboxTasks = try await fetchInboxTasks.execute()
                guard let self else { return }
                self.state.inboxTasksForSheet = inboxTasks.map { $0.task }
                self.state.isLoadingInboxTasks = false
            } catch {
                guard let self else { return }
                self.state.isLoadingInboxTasks = false
                self.state.addTaskFailureMessage = error.localizedDescription
            }
        }
    }

    private func addInboxTaskToGoal(task: AwanTask, goalID: UUID) {
        guard let addTaskToGoal = useCases.addTaskToGoal else { return }
        state.addTaskSheetGoalID = nil
        state.inboxTasksForSheet = []
        Task { [weak self] in
            do {
                try await addTaskToGoal.execute(goalID: goalID, task: task)
                guard let self else { return }
                self.loadGoalTasks(goalID: goalID)
            } catch {
                guard let self else { return }
                let errorString = String(describing: error)
                if errorString.contains("400") || errorString.contains("409") || errorString.lowercased().contains("dependenc") {
                    self.state.addTaskFailureMessage = "Remove this task's dependencies before moving it to another goal"
                } else {
                    self.state.addTaskFailureMessage = error.localizedDescription
                }
            }
        }
    }


    public func loadGoalTasks(goalID: UUID) {
        state.isLoadingGoalTasks = true
        state.goalTasksFailureMessage = nil
        state.selectedGoalTasks = []
        state.orderedGoalTasks = []

        let fetchGoalTasks = useCases.fetchGoalTasks

        Task { [weak self] in
            do {
                let tasks = try await fetchGoalTasks.execute(goalID: goalID)
                guard let self else { return }
                self.state.isLoadingGoalTasks = false
                self.state.selectedGoalTasks = tasks
                self.state.orderedGoalTasks = Self.buildOrderedItems(from: tasks)
            } catch {
                guard let self else { return }
                self.state.isLoadingGoalTasks = false
                self.state.goalTasksFailureMessage = error.localizedDescription
            }
        }
    }

    

    private static func buildOrderedItems(from tasks: [AwanTask]) -> [GoalDetailTaskItem] {
        let knownIDs = Set(tasks.map(\.id))
        let taskByID = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })
      
        let originalIndex = Dictionary(uniqueKeysWithValues: tasks.enumerated().map { ($0.element.id, $0.offset) })

        
        let localDepIDs: [UUID: Set<UUID>] = Dictionary(
            uniqueKeysWithValues: tasks.map { task in
                (task.id, task.dependencyIDs.filter { knownIDs.contains($0) })
            }
        )

       
        var dependents: [UUID: [UUID]] = [:]
        for task in tasks {
            for depID in localDepIDs[task.id, default: []] {
                dependents[depID, default: []].append(task.id)
            }
        }

      
        var inDegree: [UUID: Int] = Dictionary(
            uniqueKeysWithValues: tasks.map { ($0.id, localDepIDs[$0.id, default: []].count) }
        )

        var queue: [AwanTask] = tasks
            .filter { (inDegree[$0.id] ?? 0) == 0 }
            .sorted { (originalIndex[$0.id] ?? 0) < (originalIndex[$1.id] ?? 0) }

        var ordered: [AwanTask] = []

        while !queue.isEmpty {
            let task = queue.removeFirst()
            ordered.append(task)

           
            let newlyEligible = (dependents[task.id] ?? [])
                .compactMap { taskByID[$0] }
                .filter {
                    inDegree[$0.id, default: 0] -= 1
                    return inDegree[$0.id] == 0
                }
                .sorted { (originalIndex[$0.id] ?? 0) < (originalIndex[$1.id] ?? 0) }
            queue.append(contentsOf: newlyEligible)
        }

       
        if ordered.count != tasks.count {
            ordered = tasks
        }

        let displayIndexByTaskID = Dictionary(
            uniqueKeysWithValues: ordered.enumerated().map {
                ($0.element.id, $0.offset + 1)
            }
        )

        let result = ordered.enumerated().map { index, sortedTask -> GoalDetailTaskItem in
            let localDeps = localDepIDs[sortedTask.id, default: []]
            let dependencyIndices = localDeps
                .compactMap { displayIndexByTaskID[$0] }
                .sorted()
            return GoalDetailTaskItem(
                displayIndex: index + 1,
                isDependent: !localDeps.isEmpty,
                dependencyIndices: dependencyIndices,
                task: taskByID[sortedTask.id] ?? sortedTask
            )
        }

        return result
    }

    // MARK: - Private

    private func load() {
        cancellable?.cancel()
        state.isLoading = true
        state.failureMessage = nil

        cancellable = useCases.fetchGoalsWithTasks.observe()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    self.state.isLoading = false
                    if case let .failure(error) = completion {
                        self.state.failureMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] goalsWithTasks in
                    guard let self else { return }
                    self.state.isLoading = false
                    self.state.allGoals = self.mapper.map(goals: goalsWithTasks)
                }
            )
    }
}

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
        case .dismissError:
            state.failureMessage = nil
            state.goalTasksFailureMessage = nil
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

        let result = ordered.enumerated().map { index, sortedTask -> GoalDetailTaskItem in
            let localDeps = localDepIDs[sortedTask.id, default: []]
            let depNames = localDeps
                .sorted { (originalIndex[$0] ?? 0) < (originalIndex[$1] ?? 0) }
                .compactMap { taskByID[$0]?.title }
            return GoalDetailTaskItem(
                displayIndex: index + 1,
                isDependent: !localDeps.isEmpty,
                dependencyNames: depNames,
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

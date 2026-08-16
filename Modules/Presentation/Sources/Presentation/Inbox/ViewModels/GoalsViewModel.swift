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
    @ObservationIgnored private var isObserving = false

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
        case .appeared:
            guard !isObserving else { return }
            load()
        case .refresh:
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
        case let .showEditGoalSheet(goalID):
            state.editGoalSheetGoalID = goalID
        case .dismissEditGoalSheet:
            state.editGoalSheetGoalID = nil
        case let .updateGoal(goalID, title, description, targetDate):
            updateGoal(goalID: goalID, title: title, description: description, targetDate: targetDate)
        case let .deleteGoal(goalID):
            deleteGoal(goalID: goalID)
        case .dismissGoalActionError:
            state.goalActionErrorMessage = nil
        case let .requestAISchedule(goalID):
            requestAISchedule(goalID: goalID)
        case let .confirmAISchedule(goalID):
            confirmAISchedule(goalID: goalID)
        case .dismissAIScheduleReview:
            state.scheduleReviewGoalID = nil
            state.scheduleReviewTasks = []
            state.showsUnscheduledDialog = false
            state.scheduleFocusedTaskID = nil
        case let .toggleScheduleSuggestion(sessionID):
            toggleScheduleSuggestion(sessionID: sessionID)
        case let .updateScheduleSession(sessionID, start, end):
            updateScheduleSession(sessionID: sessionID, start: start, end: end)
        case let .addManualScheduleSession(taskID, start, end):
            addManualScheduleSession(taskID: taskID, start: start, end: end)
        case let .removeManualScheduleSession(sessionID):
            removeManualScheduleSession(sessionID: sessionID)
        case let .prepareScheduleConfirmation(goalID):
            prepareScheduleConfirmation(goalID: goalID)
        case let .continueWithoutUnscheduledTasks(goalID):
            state.showsUnscheduledDialog = false
            confirmAISchedule(goalID: goalID)
        case let .acceptAllSuggestionsAndConfirm(goalID):
            acceptAllSuggestionsAndConfirm(goalID: goalID)
        case .focusFirstUnscheduledTask:
            state.showsUnscheduledDialog = false
            state.scheduleFocusedTaskID = state.unresolvedScheduleTasks.first?.taskID
        case .dismissUnscheduledDialog:
            state.showsUnscheduledDialog = false
        case .clearFocusedUnscheduledTask:
            state.scheduleFocusedTaskID = nil
        case .dismissScheduleErrorMessage:
            state.scheduleErrorMessage = nil
        case let .completeTask(id):
            completeTask(id: id)
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

    private func updateGoal(goalID: UUID, title: String, description: String?, targetDate: Date?) {
        guard let updateGoalUseCase = useCases.updateGoal else { return }
        state.isUpdatingGoal = true
        state.editGoalSheetGoalID = nil

        Task { [weak self] in
            do {
                _ = try await updateGoalUseCase.execute(
                    id: goalID,
                    title: title,
                    description: description,
                    targetDate: targetDate
                )
                guard let self else { return }
                self.state.isUpdatingGoal = false
            } catch {
                guard let self else { return }
                self.state.isUpdatingGoal = false
                self.state.goalActionErrorMessage = error.localizedDescription
            }
        }
    }

    private func deleteGoal(goalID: UUID) {
        guard let deleteGoalUseCase = useCases.deleteGoal else { return }
        state.isDeletingGoal = true

        Task { [weak self] in
            do {
                try await deleteGoalUseCase.execute(id: goalID)
                guard let self else { return }
                self.state.isDeletingGoal = false
                self.state.allGoals.removeAll { $0.id == goalID }
                self.state.deletedGoalID = goalID
            } catch {
                guard let self else { return }
                self.state.isDeletingGoal = false
                self.state.goalActionErrorMessage = error.localizedDescription
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

        let fetchGoalsWithTasks = useCases.fetchGoalsWithTasks
        let fetchGoalTasks = useCases.fetchGoalTasks

        Task { [weak self] in
            do {
                let goalsWithTasks = try await fetchGoalsWithTasks.execute()
                guard let self else { return }

                if let targetGoal = goalsWithTasks.first(where: { $0.goal.id == goalID }) {
                    let mapper = InboxStateMapper()
                    let mappedInboxItems = mapper.map(inboxTasks: targetGoal.tasks)
                    let inboxItemsByTaskID = Dictionary(
                        mappedInboxItems.map { ($0.id, $0) },
                        uniquingKeysWith: { first, _ in first }
                    )

                    let rawTasks = targetGoal.tasks.map(\.task)
                    self.state.isLoadingGoalTasks = false
                    self.state.selectedGoalTasks = rawTasks
                    self.state.orderedGoalTasks = Self.buildOrderedItems(
                        from: rawTasks,
                        inboxItemsByTaskID: inboxItemsByTaskID
                    )
                } else {
                    let tasks = try await fetchGoalTasks.execute(goalID: goalID)
                    self.state.isLoadingGoalTasks = false
                    self.state.selectedGoalTasks = tasks
                    self.state.orderedGoalTasks = Self.buildOrderedItems(from: tasks)
                }
            } catch {
                guard let self else { return }
                self.state.isLoadingGoalTasks = false
                self.state.goalTasksFailureMessage = error.localizedDescription
            }
        }
    }

    private func completeTask(id: UUID) {
        guard let index = state.orderedGoalTasks.firstIndex(where: { $0.id == id }) else { return }
        let current = state.orderedGoalTasks[index]
        let isCurrentlyCompleted = current.task.completedAt != nil || current.task.status == .completed
        let newCompletedState = !isCurrentlyCompleted
        let newCompletedAt: Date? = newCompletedState ? Date() : nil

        let updatedTask = current.task.updatingCompletion(newCompletedAt)

        state.orderedGoalTasks[index] = GoalDetailTaskItem(
            displayIndex: current.displayIndex,
            isDependent: current.isDependent,
            dependencyIndices: current.dependencyIndices,
            task: updatedTask,
            sessionsSummary: current.sessionsSummary,
            sessionItems: current.sessionItems
        )

        guard let setTaskCompletion = useCases.setTaskCompletion else { return }

        Task { [weak self] in
            do {
                let result = try await setTaskCompletion.execute(
                    taskID: id,
                    isCompleted: newCompletedState
                )
                guard let self else { return }
                if let idx = self.state.orderedGoalTasks.firstIndex(where: { $0.id == id }) {
                    let item = self.state.orderedGoalTasks[idx]
                    self.state.orderedGoalTasks[idx] = GoalDetailTaskItem(
                        displayIndex: item.displayIndex,
                        isDependent: item.isDependent,
                        dependencyIndices: item.dependencyIndices,
                        task: result.task,
                        sessionsSummary: item.sessionsSummary,
                        sessionItems: item.sessionItems
                    )
                }
            } catch {
                guard let self else { return }
                if let idx = self.state.orderedGoalTasks.firstIndex(where: { $0.id == id }) {
                    self.state.orderedGoalTasks[idx] = current
                }
            }
        }
    }

    private static func buildOrderedItems(
        from tasks: [AwanTask],
        inboxItemsByTaskID: [UUID: InboxTaskItem] = [:]
    ) -> [GoalDetailTaskItem] {
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
            let inboxItem = inboxItemsByTaskID[sortedTask.id]
            return GoalDetailTaskItem(
                displayIndex: index + 1,
                isDependent: !localDeps.isEmpty,
                dependencyIndices: dependencyIndices,
                task: taskByID[sortedTask.id] ?? sortedTask,
                sessionsSummary: inboxItem?.sessionsSummary ?? "",
                sessionItems: inboxItem?.sessionItems ?? []
            )
        }

        return result
    }

    // MARK: - AI Scheduling

    private func requestAISchedule(goalID: UUID) {
        guard let requestScheduleUseCase = useCases.requestSchedule else { return }
        state.isRequestingAISchedule = true
        state.scheduleErrorMessage = nil

        Task { [weak self] in
            do {
                let proposal = try await requestScheduleUseCase.execute(goalID: goalID)
                guard let self else { return }
                let tasks = self.state.selectedGoalTasks
                self.state.scheduleReviewTasks = GoalScheduleReviewMapper.tasks(
                    proposal: proposal,
                    tasks: tasks
                )
                self.state.scheduleReviewGoalID = goalID
                self.state.isRequestingAISchedule = false
                await self.loadScheduleZoneNames()
            } catch {
                guard let self else { return }
                self.state.isRequestingAISchedule = false
                self.state.scheduleErrorMessage = error.localizedDescription
            }
        }
    }

    private func prepareScheduleConfirmation(goalID: UUID) {
        if !state.unresolvedScheduleTasks.isEmpty {
            state.scheduleFocusedTaskID = nil
            state.showsUnscheduledDialog = true
            return
        }
        confirmAISchedule(goalID: goalID)
    }

    private func acceptAllSuggestionsAndConfirm(goalID: UUID) {
        for taskIndex in state.scheduleReviewTasks.indices {
            for sessionIndex in state.scheduleReviewTasks[taskIndex].sessions.indices
            where state.scheduleReviewTasks[taskIndex].sessions[sessionIndex].isSuggestion {
                state.scheduleReviewTasks[taskIndex].sessions[sessionIndex].isAccepted = true
            }
        }
        state.showsUnscheduledDialog = false
        confirmAISchedule(goalID: goalID)
    }

    private func confirmAISchedule(goalID: UUID) {
        guard let confirmScheduleUseCase = useCases.confirmSchedule else { return }
        let items = state.scheduleReviewTasks
            .flatMap(\.sessions)
            .filter(\.isIncluded)
            .map {
                GoalScheduleConfirmationItem(
                    taskID: $0.taskID,
                    zoneID: $0.zoneID,
                    start: $0.start,
                    end: $0.end
                )
            }
        guard !items.isEmpty else {
            state.scheduleReviewGoalID = nil
            state.scheduleReviewTasks = []
            return
        }

        state.isConfirmingAISchedule = true
        state.scheduleErrorMessage = nil

        Task { [weak self] in
            do {
                _ = try await confirmScheduleUseCase.execute(
                    goalID: goalID,
                    sessions: items
                )
                guard let self else { return }
                self.state.isConfirmingAISchedule = false
                self.state.scheduleReviewGoalID = nil
                self.state.scheduleReviewTasks = []
                self.state.showsUnscheduledDialog = false
                self.load()
            } catch {
                guard let self else { return }
                self.state.isConfirmingAISchedule = false
                self.state.scheduleErrorMessage = error.localizedDescription
            }
        }
    }

    private func toggleScheduleSuggestion(sessionID: UUID) {
        mutateScheduleSession(id: sessionID) { $0.isAccepted.toggle() }
    }

    private func updateScheduleSession(sessionID: UUID, start: Date, end: Date) {
        mutateScheduleSession(id: sessionID) {
            $0.zoneID = nil
            $0.start = start
            $0.end = end
            $0.kind = .manual
            $0.isEdited = false
            $0.isAccepted = true
        }
    }

    private func addManualScheduleSession(taskID: UUID, start: Date, end: Date) {
        guard let taskIndex = state.scheduleReviewTasks.firstIndex(where: {
            $0.taskID == taskID
        }) else { return }

        state.scheduleReviewTasks[taskIndex].sessions.append(
            GoalScheduleReviewSession(
                id: UUID(),
                taskID: taskID,
                zoneID: nil,
                start: start,
                end: end,
                kind: .manual,
                isAccepted: true,
                isEdited: false
            )
        )
        state.scheduleReviewTasks[taskIndex].unscheduledMessage = nil
    }

    private func removeManualScheduleSession(sessionID: UUID) {
        for taskIndex in state.scheduleReviewTasks.indices {
            state.scheduleReviewTasks[taskIndex].sessions.removeAll {
                $0.id == sessionID && $0.isManual
            }
        }
    }

    private func mutateScheduleSession(
        id: UUID,
        mutation: (inout GoalScheduleReviewSession) -> Void
    ) {
        for taskIndex in state.scheduleReviewTasks.indices {
            guard let sessionIndex = state.scheduleReviewTasks[taskIndex].sessions
                .firstIndex(where: { $0.id == id }) else {
                continue
            }
            mutation(&state.scheduleReviewTasks[taskIndex].sessions[sessionIndex])
            return
        }
    }

    private func loadScheduleZoneNames() async {
        guard let fetchZones = useCases.fetchZones else { return }
        let days = Set(
            state.scheduleReviewTasks
                .flatMap(\.sessions)
                .map { Calendar.current.startOfDay(for: $0.start) }
        )
        for day in days {
            guard let zones = try? await fetchZones.execute(for: day) else {
                continue
            }
            for zone in zones {
                state.scheduleZoneNames[zone.id] = zone.name
            }
        }
    }

    // MARK: - Private

    private func load() {
        isObserving = true
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

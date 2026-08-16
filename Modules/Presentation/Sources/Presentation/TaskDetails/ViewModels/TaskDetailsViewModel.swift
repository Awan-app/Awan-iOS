import Combine
import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class TaskDetailsViewModel {
    private(set) var state: TaskDetailsState
    @ObservationIgnored private let useCases: TaskDetailsUseCases
    @ObservationIgnored private var categoryCancellable: AnyCancellable?

    public init(taskID: UUID, useCases: TaskDetailsUseCases) {
        state = TaskDetailsState(taskID: taskID)
        self.useCases = useCases
    }

    func send(_ action: TaskDetailsAction) {
        switch action {
        case .appeared: load()
        case .setTitle(let value): state.title = value
        case .setDescription(let value): state.description = value
        case .setMandatory(let value): state.mandatory = value
        case .setSplittable(let value): state.isSplittable = value
        case .setCategory(let id): state.selectedCategoryID = id
        case .retryCategories: loadCategories()
        case .save: save()
        case .attemptDismiss: attemptDismiss()
        case .discardAndDismiss:
            state.confirmation = nil
            state.shouldDismiss = true
        case .requestDeleteTask: state.confirmation = .deleteTask
        case .requestDeleteSession(let id): state.confirmation = .deleteSession(id)
        case .requestRemoveGoal: state.confirmation = .removeGoal
        case .requestRemoveDependency(let id): state.confirmation = .removeDependency(id)
        case .confirmAction: confirmAction()
        case .cancelConfirmation: state.confirmation = nil
        case .showGoals: loadGoals()
        case .showDependencies: loadDependencyCandidates()
        case .showAddSession: state.presentedSheet = .newSession
        case .editSession(let session): state.presentedSheet = .session(session)
        case .dismissPresentedSheet: state.presentedSheet = nil
        case .selectGoal(let goal): addToGoal(goal)
        case .selectDependency(let task): addDependency(task)
        case .createSession(let start, let end): createSession(start: start, end: end)
        case .saveSession(let sessionID, let start, let end):
            updateSession(sessionID: sessionID, start: start, end: end)
        case .dismissError: state.errorMessage = nil
        }
    }

    private func load() {
        guard !state.isLoading else { return }
        loadCategories()
        loadZones()
        state.isLoading = true
        state.errorMessage = nil
        Task { [weak self] in
            guard let self else { return }
            do {
                async let snapshot = useCases.fetch.execute(taskID: state.taskID)
                async let profile = useCases.userProfile.execute()
                apply(try await snapshot, resetDraft: true)
                state.timeZoneIdentifier = try await profile.preferences.timezone
                state.isLoading = false
            } catch is CancellationError {
                state.isLoading = false
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
            }
        }
    }

    private func refreshSnapshot(resetDraft: Bool = false) async throws {
        let snapshot = try await useCases.fetch.execute(taskID: state.taskID)
        apply(snapshot, resetDraft: resetDraft)
    }

    private func apply(_ snapshot: TaskDetailsSnapshot, resetDraft: Bool) {
        state.snapshot = snapshot
        guard resetDraft else { return }
        state.title = snapshot.task.title
        state.description = snapshot.task.description ?? ""
        state.mandatory = snapshot.task.mandatory
        state.isSplittable = snapshot.task.isSplittable
        state.selectedCategoryID = snapshot.task.category?.id
        state.originalTitle = state.title
        state.originalDescription = state.description
        state.originalMandatory = state.mandatory
        state.originalIsSplittable = state.isSplittable
        state.originalCategoryID = state.selectedCategoryID
    }

    private func save() {
        guard state.canSave else { return }
        state.isSaving = true
        state.errorMessage = nil
        let request = EditTaskDetailsRequest(
            taskID: state.taskID,
            title: state.title,
            description: state.description,
            mandatory: state.mandatory,
            isSplittable: state.isSplittable,
            category: selectedCategory
        )
        Task { [weak self] in
            guard let self else { return }
            do {
                let acceptedTask = try await useCases.edit.execute(request)
                if let snapshot = state.snapshot {
                    apply(
                        TaskDetailsSnapshot(
                            task: acceptedTask,
                            sessions: snapshot.sessions,
                            goal: snapshot.goal,
                            dependencies: snapshot.dependencies
                        ),
                        resetDraft: true
                    )
                }
                state.isSaving = false
                state.shouldDismiss = true
            } catch is CancellationError {
                state.isSaving = false
            } catch {
                state.isSaving = false
                state.errorMessage = error.localizedDescription
            }
        }
    }

    private var selectedCategory: TaskCategory? {
        guard let selectedCategoryID = state.selectedCategoryID else { return nil }
        return state.categories.first { $0.id == selectedCategoryID }
            ?? state.snapshot?.task.category
    }

    private func loadCategories() {
        categoryCancellable?.cancel()
        state.categoryErrorMessage = nil
        categoryCancellable = useCases.fetchCategories.observe()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard case .failure(let error) = completion else { return }
                    self?.state.categoryErrorMessage = error.localizedDescription
                },
                receiveValue: { [weak self] categories in
                    self?.state.categories = categories
                }
            )
    }

    private func loadZones() {
        Task { [weak self] in
            guard let self else { return }
            do {
                state.zones = try await useCases.fetchZones.execute(for: .now)
            } catch is CancellationError {
                return
            } catch {
                if state.categoryErrorMessage == nil {
                    state.categoryErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func attemptDismiss() {
        guard !state.isBusy else { return }
        if state.isDirty {
            state.confirmation = .discardChanges
        } else {
            state.shouldDismiss = true
        }
    }

    private func confirmAction() {
        guard let confirmation = state.confirmation,
              let snapshot = state.snapshot else { return }
        state.confirmation = nil
        state.isMutating = true
        Task { [weak self] in
            guard let self else { return }
            do {
                switch confirmation {
                case .discardChanges:
                    state.isMutating = false
                    state.shouldDismiss = true
                    return
                case .deleteTask:
                    try await useCases.deleteTask.execute(taskID: state.taskID)
                    state.isMutating = false
                    state.shouldDismiss = true
                    return
                case .deleteSession(let id):
                    try await useCases.deleteSession.execute(sessionID: id)
                case .removeGoal:
                    let accepted = try await useCases.removeFromGoal.execute(snapshot.task)
                    applyMovedTask(accepted, goal: nil)
                    state.isMutating = false
                    return
                case .removeDependency(let id):
                    try await useCases.removeDependency.execute(
                        taskID: state.taskID,
                        dependencyID: id
                    )
                }
                try await refreshSnapshot()
                state.isMutating = false
            } catch is CancellationError {
                state.isMutating = false
            } catch {
                state.isMutating = false
                state.errorMessage = error.localizedDescription
            }
        }
    }

    private func loadGoals() {
        state.isMutating = true
        Task { [weak self] in
            guard let self else { return }
            do {
                state.goals = try await useCases.fetchGoals.execute()
                    .filter { $0.id != state.snapshot?.goal?.id }
                state.isMutating = false
                state.presentedSheet = .goals
            } catch {
                state.isMutating = false
                state.errorMessage = error.localizedDescription
            }
        }
    }

    private func loadDependencyCandidates() {
        guard let task = state.snapshot?.task else { return }
        state.isMutating = true
        Task { [weak self] in
            guard let self else { return }
            do {
                state.dependencyCandidates = try await useCases.fetchDependencyCandidates
                    .execute(task: task)
                state.isMutating = false
                state.presentedSheet = .dependencies
            } catch {
                state.isMutating = false
                state.errorMessage = error.localizedDescription
            }
        }
    }

    private func addToGoal(_ goal: Goal) {
        guard let task = state.snapshot?.task else { return }
        state.presentedSheet = nil
        state.isMutating = true
        Task { [weak self] in
            guard let self else { return }
            do {
                let accepted = try await useCases.addToGoal.execute(
                    goalID: goal.id,
                    task: task
                )
                applyMovedTask(accepted, goal: goal)
                state.isMutating = false
            } catch {
                state.isMutating = false
                state.errorMessage = error.localizedDescription
            }
        }
    }

    private func addDependency(_ task: AwanTask) {
        guard let currentTask = state.snapshot?.task else { return }
        state.presentedSheet = nil
        state.isMutating = true
        Task { [weak self] in
            guard let self else { return }
            do {
                try await useCases.addDependency.execute(
                    task: currentTask,
                    dependency: task
                )
                if let snapshot = state.snapshot {
                    apply(
                        TaskDetailsSnapshot(
                            task: snapshot.task,
                            sessions: snapshot.sessions,
                            goal: snapshot.goal,
                            dependencies: snapshot.dependencies + [task]
                        ),
                        resetDraft: false
                    )
                }
                try? await refreshSnapshot()
                state.isMutating = false
            } catch {
                state.isMutating = false
                state.errorMessage = error.localizedDescription
            }
        }
    }

    private func applyMovedTask(_ task: AwanTask, goal: Goal?) {
        guard let snapshot = state.snapshot else { return }
        apply(
            TaskDetailsSnapshot(
                task: task,
                sessions: snapshot.sessions,
                goal: goal,
                dependencies: snapshot.dependencies
            ),
            resetDraft: false
        )
        state.dependencyCandidates = []
    }

    private func updateSession(sessionID: UUID, start: Date, end: Date) {
        state.presentedSheet = nil
        state.isMutating = true
        let request = UpdateSessionScheduleRequest(
            sessionID: sessionID,
            selectedDay: start,
            start: start,
            end: end,
            timeZoneIdentifier: state.timeZoneIdentifier
        )
        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await useCases.updateSession.execute(request)
                try await refreshSnapshot()
                state.isMutating = false
            } catch {
                state.isMutating = false
                state.errorMessage = error.localizedDescription
            }
        }
    }

    private func createSession(start: Date, end: Date) {
        state.presentedSheet = nil
        state.isMutating = true
        let request = CreateTaskSessionRequest(
            taskID: state.taskID,
            start: start,
            end: end
        )
        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await useCases.createSession.execute(request)
                try await refreshSnapshot()
                state.isMutating = false
            } catch is CancellationError {
                state.isMutating = false
            } catch {
                state.isMutating = false
                state.errorMessage = error.localizedDescription
            }
        }
    }
}

//
//  InboxViewModel.swift
//  Presentation
//

import Combine
import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class InboxViewModel {
    public var state: InboxState

    @ObservationIgnored private let useCases: InboxUseCases
    @ObservationIgnored private let mapper: InboxStateMapper
    @ObservationIgnored private var cancellable: AnyCancellable?

    public init(
        useCases: InboxUseCases,
        mapper: InboxStateMapper = InboxStateMapper()
    ) {
        self.useCases = useCases
        self.mapper = mapper
        self.state = InboxState()
    }

    public func send(_ action: InboxAction) {
        switch action {
        case .appeared, .refresh:
            load()
        case let .searchQueryChanged(query):
            state.searchQuery = query
        case let .taskFilterChanged(filter):
            state.selectedTaskFilter = filter
        case let .sessionFilterChanged(filter):
            state.selectedSessionFilter = filter
        case let .toggleTaskExpansion(id):
            if state.expandedTaskIDs.contains(id) {
                state.expandedTaskIDs.remove(id)
            } else {
                state.expandedTaskIDs.insert(id)
            }
        case let .completeTask(id):
            completeTask(id: id)
        case let .deleteTask(id):
            deleteTask(id: id)
        case let .selectTopTab(tab):
            state.selectedTopTab = tab
            
        case .dismissError:
            state.failureMessage = nil
        case .dismissStreakTransition:
            state.streakTransition = nil
        }
    }

    private func completeTask(id: UUID) {
        guard let setTaskCompletion = useCases.setTaskCompletion,
              !state.mutatingTaskIDs.contains(id),
              let index = state.allTasks.firstIndex(where: { $0.id == id }) else {
            return
        }
        let current = state.allTasks[index]
        let isCurrentlyCompleted = current.rawTask.completedAt != nil
        let newCompletedState = !isCurrentlyCompleted
        let newDerivedStatus: InboxTaskStatus = newCompletedState
            ? .completed
            : reopenedStatus(for: current)

        state.allTasks[index] = replacing(
            current,
            task: current.rawTask.updatingCompletion(
                newCompletedState ? Date() : nil
            ),
            derivedStatus: newDerivedStatus
        )
        state.mutatingTaskIDs.insert(id)

        Task { [weak self] in
            defer { self?.state.mutatingTaskIDs.remove(id) }
            do {
                let result = try await setTaskCompletion.execute(
                    taskID: id,
                    isCompleted: newCompletedState
                )
                guard let self else { return }
                self.applyAcceptedTask(result.task)

                if case .completed(let completion) = result,
                   completion.reward.streak.updated {
                    self.state.streakTransition = InboxStreakTransition(
                        oldValue: completion.reward.streak.oldValue,
                        newValue: completion.reward.streak.newValue,
                        isNewRecord: completion.reward.streak.maxStreakBroken
                    )
                } else {
                    self.state.streakTransition = nil
                }
            } catch {
                guard let self else { return }
                if let currentIndex = self.state.allTasks.firstIndex(where: { $0.id == id }) {
                    self.state.allTasks[currentIndex] = current
                }
                self.state.failureMessage = error.localizedDescription
            }
        }
    }

    private func applyAcceptedTask(_ task: AwanTask) {
        guard let index = state.allTasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        let current = state.allTasks[index]
        state.allTasks[index] = replacing(
            current,
            task: task,
            derivedStatus: presentationStatus(for: task, item: current)
        )
    }

    private func replacing(
        _ item: InboxTaskItem,
        task: AwanTask,
        derivedStatus: InboxTaskStatus
    ) -> InboxTaskItem {
        InboxTaskItem(
            id: task.id,
            title: task.title,
            description: task.description,
            derivedStatus: derivedStatus,
            sessionsSummary: item.sessionsSummary,
            sessionItems: item.sessionItems,
            rawTask: task,
            availableCompletionPoints: item.availableCompletionPoints
        )
    }

    private func presentationStatus(
        for task: AwanTask,
        item: InboxTaskItem
    ) -> InboxTaskStatus {
        if task.completedAt != nil {
            return .completed
        }

        return derivedStatus(from: item.sessionItems)
    }

    private func derivedStatus(
        from sessions: [InboxSessionItem]
    ) -> InboxTaskStatus {
        guard !sessions.isEmpty else { return .drafted }
        let nonCancelled = sessions.filter {
            $0.underlyingStatus != .cancelled
        }
        guard !nonCancelled.isEmpty else { return .cancelled }
        return .active
    }

    private func reopenedStatus(for item: InboxTaskItem) -> InboxTaskStatus {
        derivedStatus(from: item.sessionItems)
    }

    private func deleteTask(id: UUID) {
        Task {
            do {
                try await useCases.deleteInboxTask?.execute(taskID: id)
            } catch {
                self.state.failureMessage = error.localizedDescription
            }
        }
    }

    private func load() {
        cancellable?.cancel()
        state.isLoading = true
        state.failureMessage = nil

        cancellable = useCases.fetchInboxTasks.observe()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    self.state.isLoading = false
                    if case let .failure(error) = completion {
                        self.state.failureMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] inboxTasks in
                    guard let self else { return }
                    self.state.isLoading = false
                    self.state.allTasks = self.mapper.map(inboxTasks: inboxTasks)
                }
            )
    }
}

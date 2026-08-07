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
    public var goalsViewModel: GoalsViewModel?

    @ObservationIgnored private let useCases: InboxUseCases
    @ObservationIgnored private let mapper: InboxStateMapper
    @ObservationIgnored private var cancellable: AnyCancellable?

    public init(
        useCases: InboxUseCases,
        mapper: InboxStateMapper = InboxStateMapper(),
        goalsViewModel: GoalsViewModel? = nil
    ) {
        self.useCases = useCases
        self.mapper = mapper
        self.goalsViewModel = goalsViewModel
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
        }
    }

    private func completeTask(id: UUID) {
        guard let index = state.allTasks.firstIndex(where: { $0.id == id }) else { return }
        let current = state.allTasks[index]
        let isCurrentlyCompleted = current.derivedStatus == .completed
        let newCompletedState = !isCurrentlyCompleted
        let newDerivedStatus: InboxTaskStatus = newCompletedState
            ? .completed
            : (current.sessionItems.isEmpty ? .drafted : .active)

        let updatedItem = InboxTaskItem(
            id: current.id,
            title: current.title,
            description: current.description,
            derivedStatus: newDerivedStatus,
            sessionsSummary: current.sessionsSummary,
            sessionItems: current.sessionItems,
            rawTask: current.rawTask
        )
        state.allTasks[index] = updatedItem

        Task {
            do {
                try await useCases.completeTask?.execute(taskID: id, isCompleted: newCompletedState)
            } catch {
                self.state.failureMessage = error.localizedDescription
                load()
            }
        }
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

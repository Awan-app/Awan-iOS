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
        case .dismissError:
            state.failureMessage = nil
        }
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

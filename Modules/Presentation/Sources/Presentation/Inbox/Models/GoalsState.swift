//
//  GoalsState.swift
//  Presentation
//

import Domain
import Foundation

public struct GoalsState: Equatable, Sendable {
    public var isLoading: Bool
    public var searchQuery: String
    public var allGoals: [GoalProgressItem]
    public var failureMessage: String?

    public init(
        isLoading: Bool = false,
        searchQuery: String = "",
        allGoals: [GoalProgressItem] = [],
        failureMessage: String? = nil
    ) {
        self.isLoading = isLoading
        self.searchQuery = searchQuery
        self.allGoals = allGoals
        self.failureMessage = failureMessage
    }

    public var filteredGoals: [GoalProgressItem] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return allGoals }
        return allGoals.filter { goal in
            goal.title.localizedCaseInsensitiveContains(query)
            || (goal.description?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
}

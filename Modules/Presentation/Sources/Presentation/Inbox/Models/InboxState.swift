//
//  InboxState.swift
//  Presentation
//

import Domain
import Foundation

public struct InboxState: Equatable, Sendable {
    public var selectedTopTab: InboxTopTab
    public var isLoading: Bool
    public var searchQuery: String
    public var selectedTaskFilter: InboxTaskFilter
    public var selectedSessionFilter: InboxSessionFilter
    public var expandedTaskIDs: Set<UUID>
    public var allTasks: [InboxTaskItem]
    public var failureMessage: String?

    public init(
        selectedTopTab: InboxTopTab = .inbox,
        isLoading: Bool = false,
        searchQuery: String = "",
        selectedTaskFilter: InboxTaskFilter = .all,
        selectedSessionFilter: InboxSessionFilter = .any,
        expandedTaskIDs: Set<UUID> = [],
        allTasks: [InboxTaskItem] = [],
        failureMessage: String? = nil
    ) {
        self.selectedTopTab = selectedTopTab
        self.isLoading = isLoading
        self.searchQuery = searchQuery
        self.selectedTaskFilter = selectedTaskFilter
        self.selectedSessionFilter = selectedSessionFilter
        self.expandedTaskIDs = expandedTaskIDs
        self.allTasks = allTasks
        self.failureMessage = failureMessage
      
    }

    public var filteredTasks: [InboxTaskItem] {
        allTasks.filter { taskItem in
            let passesTaskFilter: Bool
            switch selectedTaskFilter {
            case .all:
                passesTaskFilter = true
            case .drafted:
                passesTaskFilter = taskItem.derivedStatus == .drafted
            case .active:
                passesTaskFilter = taskItem.derivedStatus == .active
            case .completed:
                passesTaskFilter = taskItem.derivedStatus == .completed
            }
            guard passesTaskFilter else { return false }

            // 2. Session filter
            let passesSessionFilter: Bool
            switch selectedSessionFilter {
            case .any:
                passesSessionFilter = true
            case .activeNow:
                passesSessionFilter = taskItem.sessionItems.contains { $0.displayStatus == .activeNow }
            case .missed:
                passesSessionFilter = taskItem.sessionItems.contains { $0.displayStatus == .missed }
            }
            guard passesSessionFilter else { return false }

            let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !query.isEmpty else { return true }

            let titleMatches = taskItem.title.localizedCaseInsensitiveContains(query)
            let descriptionMatches = taskItem.description?.localizedCaseInsensitiveContains(query) ?? false
            let sessionMatches = taskItem.sessionItems.contains {
                $0.timeRangeText.localizedCaseInsensitiveContains(query)
            }

            return titleMatches || descriptionMatches || sessionMatches
        }
    }
}

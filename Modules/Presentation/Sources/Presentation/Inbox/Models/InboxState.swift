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
    public var userPoints: Int?
    public var completionReward: InboxCompletionReward?
    public var completionRewardAnimation: InboxCompletionRewardAnimation?
    public var mutatingTaskIDs: Set<UUID>

    public init(
        selectedTopTab: InboxTopTab = .inbox,
        isLoading: Bool = false,
        searchQuery: String = "",
        selectedTaskFilter: InboxTaskFilter = .all,
        selectedSessionFilter: InboxSessionFilter = .any,
        expandedTaskIDs: Set<UUID> = [],
        allTasks: [InboxTaskItem] = [],
        failureMessage: String? = nil,
        userPoints: Int? = nil,
        completionReward: InboxCompletionReward? = nil,
        completionRewardAnimation: InboxCompletionRewardAnimation? = nil,
        mutatingTaskIDs: Set<UUID> = []
    ) {
        self.selectedTopTab = selectedTopTab
        self.isLoading = isLoading
        self.searchQuery = searchQuery
        self.selectedTaskFilter = selectedTaskFilter
        self.selectedSessionFilter = selectedSessionFilter
        self.expandedTaskIDs = expandedTaskIDs
        self.allTasks = allTasks
        self.failureMessage = failureMessage
        self.userPoints = userPoints
        self.completionReward = completionReward
        self.completionRewardAnimation = completionRewardAnimation
        self.mutatingTaskIDs = mutatingTaskIDs
      
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

public struct InboxCompletionReward: Equatable, Sendable {
    public let pointsAwarded: Int?
    public let streakTransition: InboxStreakTransition?

    public init(
        pointsAwarded: Int?,
        streakTransition: InboxStreakTransition?
    ) {
        self.pointsAwarded = pointsAwarded
        self.streakTransition = streakTransition
    }
}

public struct InboxCompletionRewardAnimation: Equatable, Identifiable, Sendable {
    public let id = UUID()
    public let taskID: UUID
    public let oldPoints: Int
    public let newPoints: Int

    public init(
        taskID: UUID,
        oldPoints: Int,
        newPoints: Int
    ) {
        self.taskID = taskID
        self.oldPoints = oldPoints
        self.newPoints = newPoints
    }
}

public struct InboxStreakTransition: Equatable, Sendable {
    public let oldValue: Int
    public let newValue: Int
    public let isNewRecord: Bool

    public init(oldValue: Int, newValue: Int, isNewRecord: Bool) {
        self.oldValue = oldValue
        self.newValue = newValue
        self.isNewRecord = isNewRecord
    }
}

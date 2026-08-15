//
//  InboxAction.swift
//  Presentation
//

import Domain
import Foundation

public enum InboxAction: Sendable {
    case appeared
    case refresh
    case searchQueryChanged(String)
    case taskFilterChanged(InboxTaskFilter)
    case sessionFilterChanged(InboxSessionFilter)
    case toggleTaskExpansion(UUID)
    case completeTask(UUID)
    case deleteTask(UUID)
    case selectTopTab(InboxTopTab)
    case dismissError
    case dismissCompletionReward
    case dismissCompletionRewardAnimation
}


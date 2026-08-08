//
//  GoalsAction.swift
//  Presentation
//

import Foundation

public enum GoalsAction: Sendable {
    case appeared
    case refresh
    case searchQueryChanged(String)
    case selectGoal(UUID)
    case dismissError
}

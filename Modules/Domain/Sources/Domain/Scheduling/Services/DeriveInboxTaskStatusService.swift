//
//  DeriveInboxTaskStatusService.swift
//  Domain
//

import Foundation

public struct DeriveInboxTaskStatusService: Sendable {
    public init() {}

    public func derive(from sessions: [Session], taskStatus: TaskStatus = .pending) -> InboxTaskStatus {
        if taskStatus == .completed {
            return .completed
        }

        guard !sessions.isEmpty else {
            return .drafted
        }

        let nonCancelledSessions = sessions.filter { $0.status != .cancelled }

        if nonCancelledSessions.isEmpty {
            return .drafted
        }

        let hasAtLeastOneCompleted = sessions.contains { $0.status == .completed }
        let allNonCancelledAreCompleted = nonCancelledSessions.allSatisfy { $0.status == .completed }

        if allNonCancelledAreCompleted && hasAtLeastOneCompleted {
            return .completed
        }

        return .active
    }
}

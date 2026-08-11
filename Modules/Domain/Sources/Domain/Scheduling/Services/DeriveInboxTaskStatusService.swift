//
//  DeriveInboxTaskStatusService.swift
//  Domain
//

import Foundation

public struct DeriveInboxTaskStatusService: Sendable {
    public init() {}

    public func derive(
        from sessions: [Session],
        completedAt: Date?
    ) -> InboxTaskStatus {
        if completedAt != nil {
            return .completed
        }

        guard !sessions.isEmpty else {
            return .drafted
        }

        let nonCancelledSessions = sessions.filter { $0.status != .cancelled }

        if nonCancelledSessions.isEmpty {
            return .cancelled
        }

        return .active
    }
}

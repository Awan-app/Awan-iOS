//
//  InboxTask.swift
//  Domain
//

import Foundation

public struct InboxTask: Identifiable, Hashable, Sendable {
    public let task: AwanTask
    public let sessions: [Session]
    public let derivedStatus: InboxTaskStatus

    public var id: UUID { task.id }

    public init(task: AwanTask, sessions: [Session], derivedStatus: InboxTaskStatus) {
        self.task = task
        self.sessions = sessions
        self.derivedStatus = derivedStatus
    }
}

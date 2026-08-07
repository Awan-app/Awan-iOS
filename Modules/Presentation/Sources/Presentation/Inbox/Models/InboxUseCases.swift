//
//  InboxUseCases.swift
//  Presentation
//

import Domain
import Foundation

public struct InboxUseCases: Sendable {
    public let fetchInboxTasks: any FetchInboxTasksUseCase
    public let completeTask: (any CompleteTaskSessionsUseCase)?
    public let deleteInboxTask: (any DeleteInboxTaskUseCase)?

    public init(
        fetchInboxTasks: any FetchInboxTasksUseCase,
        completeTask: (any CompleteTaskSessionsUseCase)? = nil,
        deleteInboxTask: (any DeleteInboxTaskUseCase)? = nil
    ) {
        self.fetchInboxTasks = fetchInboxTasks
        self.completeTask = completeTask
        self.deleteInboxTask = deleteInboxTask
    }
}

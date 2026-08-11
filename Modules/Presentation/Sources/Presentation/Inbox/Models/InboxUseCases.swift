//
//  InboxUseCases.swift
//  Presentation
//

import Domain
import Foundation

public struct InboxUseCases: Sendable {
    public let fetchInboxTasks: any FetchInboxTasksUseCase
    public let setTaskCompletion: (any SetTaskCompletionUseCase)?
    public let deleteInboxTask: (any DeleteInboxTaskUseCase)?

    public init(
        fetchInboxTasks: any FetchInboxTasksUseCase,
        setTaskCompletion: (any SetTaskCompletionUseCase)? = nil,
        deleteInboxTask: (any DeleteInboxTaskUseCase)? = nil
    ) {
        self.fetchInboxTasks = fetchInboxTasks
        self.setTaskCompletion = setTaskCompletion
        self.deleteInboxTask = deleteInboxTask
    }
}

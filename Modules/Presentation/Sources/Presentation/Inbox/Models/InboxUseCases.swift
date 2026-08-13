//
//  InboxUseCases.swift
//  Presentation
//

import Domain
import Foundation

public struct InboxUseCases: Sendable {
    public let fetchInboxTasks: any FetchInboxTasksUseCase
    public let userProfile: (any GetUserProfileUseCase)?
    public let setTaskCompletion: (any SetTaskCompletionUseCase)?
    public let deleteInboxTask: (any DeleteInboxTaskUseCase)?
    public let fetchGoals: (any FetchGoalsUseCase)?
    public let createEmptyGoal: (any CreateEmptyGoalUseCase)?
    public let addTaskToGoal: (any AddTaskToGoalUseCase)?

    public init(
        fetchInboxTasks: any FetchInboxTasksUseCase,
        userProfile: (any GetUserProfileUseCase)? = nil,
        setTaskCompletion: (any SetTaskCompletionUseCase)? = nil,
        deleteInboxTask: (any DeleteInboxTaskUseCase)? = nil,
        fetchGoals: (any FetchGoalsUseCase)? = nil,
        createEmptyGoal: (any CreateEmptyGoalUseCase)? = nil,
        addTaskToGoal: (any AddTaskToGoalUseCase)? = nil
    ) {
        self.fetchInboxTasks = fetchInboxTasks
        self.userProfile = userProfile
        self.setTaskCompletion = setTaskCompletion
        self.deleteInboxTask = deleteInboxTask
        self.fetchGoals = fetchGoals
        self.createEmptyGoal = createEmptyGoal
        self.addTaskToGoal = addTaskToGoal
    }
}


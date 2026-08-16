//
//  GoalsUseCases.swift
//  Presentation
//

import Domain
import Foundation

public struct GoalsUseCases: Sendable {
    public let fetchGoalsWithTasks: any FetchGoalsWithTasksUseCase
    public let fetchGoalTasks: any FetchGoalTasksUseCase
    public let createEmptyGoal: (any CreateEmptyGoalUseCase)?
    public let addTaskToGoal: (any AddTaskToGoalUseCase)?
    public let fetchInboxTasks: (any FetchInboxTasksUseCase)?
    public let updateGoal: (any UpdateGoalUseCase)?
    public let deleteGoal: (any DeleteGoalUseCase)?
    public let requestSchedule: (any RequestGoalScheduleProposalUseCase)?
    public let confirmSchedule: (any ConfirmGoalScheduleUseCase)?
    public let fetchZones: (any FetchZonesUseCase)?
    public let setTaskCompletion: (any SetTaskCompletionUseCase)?
    public let userProfile: (any GetUserProfileUseCase)?

    public init(
        fetchGoalsWithTasks: any FetchGoalsWithTasksUseCase,
        fetchGoalTasks: any FetchGoalTasksUseCase,
        createEmptyGoal: (any CreateEmptyGoalUseCase)? = nil,
        addTaskToGoal: (any AddTaskToGoalUseCase)? = nil,
        fetchInboxTasks: (any FetchInboxTasksUseCase)? = nil,
        updateGoal: (any UpdateGoalUseCase)? = nil,
        deleteGoal: (any DeleteGoalUseCase)? = nil,
        requestSchedule: (any RequestGoalScheduleProposalUseCase)? = nil,
        confirmSchedule: (any ConfirmGoalScheduleUseCase)? = nil,
        fetchZones: (any FetchZonesUseCase)? = nil,
        setTaskCompletion: (any SetTaskCompletionUseCase)? = nil,
        userProfile: (any GetUserProfileUseCase)? = nil
    ) {
        self.fetchGoalsWithTasks = fetchGoalsWithTasks
        self.fetchGoalTasks = fetchGoalTasks
        self.createEmptyGoal = createEmptyGoal
        self.addTaskToGoal = addTaskToGoal
        self.fetchInboxTasks = fetchInboxTasks
        self.updateGoal = updateGoal
        self.deleteGoal = deleteGoal
        self.requestSchedule = requestSchedule
        self.confirmSchedule = confirmSchedule
        self.fetchZones = fetchZones
        self.setTaskCompletion = setTaskCompletion
        self.userProfile = userProfile
    }
}

import Domain

public struct CreationUseCases: Sendable {
    public let fetchZones: any FetchZonesUseCase
    public let createTask: any CreateTaskUseCase
    public let createAITask: any CreateAITaskUseCase
    public let imageToTasks: any ImageToTasksUseCase
    public let acceptProposedTask: any AcceptProposedTaskUseCase
    public let acceptProposedTasks: any AcceptProposedTasksUseCase
    public let userProfile: any GetUserProfileUseCase
    public let goalDecomposition: GoalDecompositionUseCases

    public init(
        fetchZones: any FetchZonesUseCase,
        createTask: any CreateTaskUseCase,
        createAITask: any CreateAITaskUseCase,
        imageToTasks: any ImageToTasksUseCase,
        acceptProposedTask: any AcceptProposedTaskUseCase,
        acceptProposedTasks: any AcceptProposedTasksUseCase,
        userProfile: any GetUserProfileUseCase,
        goalDecomposition: GoalDecompositionUseCases
    ) {
        self.fetchZones = fetchZones
        self.createTask = createTask
        self.createAITask = createAITask
        self.imageToTasks = imageToTasks
        self.acceptProposedTask = acceptProposedTask
        self.acceptProposedTasks = acceptProposedTasks
        self.userProfile = userProfile
        self.goalDecomposition = goalDecomposition
    }
}

public struct GoalDecompositionUseCases: Sendable {
    public let sendMessage: any SendGoalDecompositionMessageUseCase
    public let confirmProposal: any ConfirmGoalProposalUseCase
    public let scheduleGoal: any ScheduleCreatedGoalUseCase

    public init(
        sendMessage: any SendGoalDecompositionMessageUseCase,
        confirmProposal: any ConfirmGoalProposalUseCase,
        scheduleGoal: any ScheduleCreatedGoalUseCase
    ) {
        self.sendMessage = sendMessage
        self.confirmProposal = confirmProposal
        self.scheduleGoal = scheduleGoal
    }
}

import Domain

public struct CreationUseCases: Sendable {
    public let fetchZones: any FetchZonesUseCase
    public let fetchCategories: any FetchCategoriesUseCase
    public let createTask: any CreateTaskUseCase
    public let createAITask: any CreateAITaskUseCase
    public let imageToTasks: any ImageToTasksUseCase
    public let acceptProposedTask: any AcceptProposedTaskUseCase
    public let acceptProposedTasks: any AcceptProposedTasksUseCase
    public let userProfile: any GetUserProfileUseCase
    public let goalDecomposition: GoalDecompositionUseCases

    public init(
        fetchZones: any FetchZonesUseCase,
        fetchCategories: any FetchCategoriesUseCase,
        createTask: any CreateTaskUseCase,
        createAITask: any CreateAITaskUseCase,
        imageToTasks: any ImageToTasksUseCase,
        acceptProposedTask: any AcceptProposedTaskUseCase,
        acceptProposedTasks: any AcceptProposedTasksUseCase,
        userProfile: any GetUserProfileUseCase,
        goalDecomposition: GoalDecompositionUseCases
    ) {
        self.fetchZones = fetchZones
        self.fetchCategories = fetchCategories
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
    public let requestSchedule: any RequestGoalScheduleProposalUseCase
    public let confirmSchedule: any ConfirmGoalScheduleUseCase
    public let fetchZones: any FetchZonesUseCase

    public init(
        sendMessage: any SendGoalDecompositionMessageUseCase,
        confirmProposal: any ConfirmGoalProposalUseCase,
        requestSchedule: any RequestGoalScheduleProposalUseCase,
        confirmSchedule: any ConfirmGoalScheduleUseCase,
        fetchZones: any FetchZonesUseCase
    ) {
        self.sendMessage = sendMessage
        self.confirmProposal = confirmProposal
        self.requestSchedule = requestSchedule
        self.confirmSchedule = confirmSchedule
        self.fetchZones = fetchZones
    }
}

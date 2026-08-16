import Domain
import Foundation

public struct TaskDetailsUseCases: Sendable {
    public let fetch: any FetchTaskDetailsUseCase
    public let edit: any EditTaskDetailsUseCase
    public let fetchGoals: any FetchGoalsUseCase
    public let addToGoal: any AddTaskToGoalUseCase
    public let removeFromGoal: any RemoveTaskFromGoalUseCase
    public let fetchDependencyCandidates: any FetchTaskDependencyCandidatesUseCase
    public let addDependency: any AddTaskDependencyUseCase
    public let removeDependency: any RemoveTaskDependencyUseCase
    public let deleteTask: any DeleteTaskDetailsUseCase
    public let deleteSession: any DeleteSessionUseCase
    public let createSession: any CreateTaskSessionUseCase
    public let updateSession: any UpdateSessionScheduleUseCase
    public let userProfile: any GetUserProfileUseCase
    public let fetchCategories: any FetchCategoriesUseCase
    public let fetchZones: any FetchZonesUseCase

    public init(
        fetch: any FetchTaskDetailsUseCase,
        edit: any EditTaskDetailsUseCase,
        fetchGoals: any FetchGoalsUseCase,
        addToGoal: any AddTaskToGoalUseCase,
        removeFromGoal: any RemoveTaskFromGoalUseCase,
        fetchDependencyCandidates: any FetchTaskDependencyCandidatesUseCase,
        addDependency: any AddTaskDependencyUseCase,
        removeDependency: any RemoveTaskDependencyUseCase,
        deleteTask: any DeleteTaskDetailsUseCase,
        deleteSession: any DeleteSessionUseCase,
        createSession: any CreateTaskSessionUseCase,
        updateSession: any UpdateSessionScheduleUseCase,
        userProfile: any GetUserProfileUseCase,
        fetchCategories: any FetchCategoriesUseCase,
        fetchZones: any FetchZonesUseCase
    ) {
        self.fetch = fetch
        self.edit = edit
        self.fetchGoals = fetchGoals
        self.addToGoal = addToGoal
        self.removeFromGoal = removeFromGoal
        self.fetchDependencyCandidates = fetchDependencyCandidates
        self.addDependency = addDependency
        self.removeDependency = removeDependency
        self.deleteTask = deleteTask
        self.deleteSession = deleteSession
        self.createSession = createSession
        self.updateSession = updateSession
        self.userProfile = userProfile
        self.fetchCategories = fetchCategories
        self.fetchZones = fetchZones
    }
}

enum TaskDetailsConfirmation: Equatable {
    case discardChanges
    case deleteTask
    case deleteSession(UUID)
    case removeGoal
    case removeDependency(UUID)
}

enum TaskDetailsPresentedSheet: Identifiable {
    case goals
    case dependencies
    case newSession
    case session(Session)

    var id: String {
        switch self {
        case .goals: "goals"
        case .dependencies: "dependencies"
        case .newSession: "new-session"
        case .session(let session): "session-\(session.id.uuidString)"
        }
    }
}

struct TaskDetailsState {
    let taskID: UUID
    var snapshot: TaskDetailsSnapshot?
    var title = ""
    var description = ""
    var mandatory = true
    var isSplittable = false
    var selectedCategoryID: UUID?
    var originalTitle = ""
    var originalDescription = ""
    var originalMandatory = true
    var originalIsSplittable = false
    var originalCategoryID: UUID?
    var categories: [TaskCategory] = []
    var zones: [Zone] = []
    var categoryErrorMessage: String?
    var goals: [Goal] = []
    var dependencyCandidates: [AwanTask] = []
    var timeZoneIdentifier = TimeZone.current.identifier
    var isLoading = false
    var isSaving = false
    var isMutating = false
    var confirmation: TaskDetailsConfirmation?
    var presentedSheet: TaskDetailsPresentedSheet?
    var errorMessage: String?
    var shouldDismiss = false

    var isDirty: Bool {
        title != originalTitle
            || description != originalDescription
            || mandatory != originalMandatory
            || isSplittable != originalIsSplittable
            || selectedCategoryID != originalCategoryID
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && isDirty
            && !isBusy
    }

    var isBusy: Bool { isLoading || isSaving || isMutating }
}

enum TaskDetailsAction {
    case appeared
    case setTitle(String)
    case setDescription(String)
    case setMandatory(Bool)
    case setSplittable(Bool)
    case setCategory(UUID?)
    case retryCategories
    case save
    case attemptDismiss
    case discardAndDismiss
    case requestDeleteTask
    case requestDeleteSession(UUID)
    case requestRemoveGoal
    case requestRemoveDependency(UUID)
    case confirmAction
    case cancelConfirmation
    case showGoals
    case showDependencies
    case showAddSession
    case editSession(Session)
    case dismissPresentedSheet
    case selectGoal(Goal)
    case selectDependency(AwanTask)
    case createSession(start: Date, end: Date)
    case saveSession(sessionID: UUID, start: Date, end: Date)
    case dismissError
}

import Domain

public struct HomeReadUseCases: Sendable {
    public let tasks: any FetchTasksUseCase
    public let sessions: any FetchSessionsUseCase
    public let zones: any FetchZonesUseCase
    public let userProfile: any GetUserProfileUseCase

    public init(
        tasks: any FetchTasksUseCase,
        sessions: any FetchSessionsUseCase,
        zones: any FetchZonesUseCase,
        userProfile: any GetUserProfileUseCase
    ) {
        self.tasks = tasks
        self.sessions = sessions
        self.zones = zones
        self.userProfile = userProfile
    }
}

public struct HomeSessionUseCases: Sendable {
    public let reschedule: any RescheduleSessionUseCase
    public let setLock: any SetSessionLockUseCase
    public let setCompletion: any SetSessionCompletionUseCase
    public let delete: any DeleteSessionUseCase

    public init(
        reschedule: any RescheduleSessionUseCase,
        setLock: any SetSessionLockUseCase,
        setCompletion: any SetSessionCompletionUseCase,
        delete: any DeleteSessionUseCase
    ) {
        self.reschedule = reschedule
        self.setLock = setLock
        self.setCompletion = setCompletion
        self.delete = delete
    }
}

public struct HomeUseCases: Sendable {
    public let reads: HomeReadUseCases
    public let sessions: HomeSessionUseCases

    public init(reads: HomeReadUseCases, sessions: HomeSessionUseCases) {
        self.reads = reads
        self.sessions = sessions
    }
}

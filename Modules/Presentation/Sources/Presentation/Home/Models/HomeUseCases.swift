import Combine
import Domain
import Foundation

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

    func observe(
        for date: Date
    ) -> AnyPublisher<(
        tasks: [AwanTask],
        sessions: [Session],
        zones: [Zone],
        profile: UserProfile
    ), Error> {
        let profilePublisher = userProfile.observe()
            .share()
            .eraseToAnyPublisher()
        let schedulingPublisher = profilePublisher
            .first()
            .flatMap { _ in
                tasks.observe()
                    .map { tasks in
                        sessions.observe(taskIDs: tasks.map(\.id))
                            .map { (tasks: tasks, sessions: $0) }
                            .eraseToAnyPublisher()
                    }
                    .switchToLatest()
                    .combineLatest(zones.observe(for: date))
                    .map { taskSessions, zones in
                        (
                            tasks: taskSessions.tasks,
                            sessions: taskSessions.sessions,
                            zones: zones
                        )
                    }
            }
        return schedulingPublisher
            .combineLatest(profilePublisher)
            .map { scheduling, profile in
                (
                    tasks: scheduling.tasks,
                    sessions: scheduling.sessions,
                    zones: scheduling.zones,
                    profile: profile
                )
            }
            .eraseToAnyPublisher()
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
    public let createTask: any CreateTaskUseCase

    public init(
        reads: HomeReadUseCases,
        sessions: HomeSessionUseCases,
        createTask: any CreateTaskUseCase
    ) {
        self.reads = reads
        self.sessions = sessions
        self.createTask = createTask
    }
}

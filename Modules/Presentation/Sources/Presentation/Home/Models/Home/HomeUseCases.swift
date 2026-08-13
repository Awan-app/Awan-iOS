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
        userProfile.observe()
            .map { profile in
                Publishers.CombineLatest3(
                    tasks.observe(for: date),
                    sessions.observe(for: date),
                    zones.observe(for: date)
                )
                    .map { tasks, sessions, zones in
                        (
                            tasks: tasks,
                            sessions: sessions,
                            zones: zones,
                            profile: profile
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

public struct HomeSessionUseCases: Sendable {
    public let reschedule: any RescheduleSessionUseCase
    public let setCompletion: any SetSessionCompletionUseCase

    public init(
        reschedule: any RescheduleSessionUseCase,
        setCompletion: any SetSessionCompletionUseCase
    ) {
        self.reschedule = reschedule
        self.setCompletion = setCompletion
    }
}

public struct HomeUseCases: Sendable {
    public let reads: HomeReadUseCases
    public let sessions: HomeSessionUseCases

    public init(
        reads: HomeReadUseCases,
        sessions: HomeSessionUseCases
    ) {
        self.reads = reads
        self.sessions = sessions
    }
}

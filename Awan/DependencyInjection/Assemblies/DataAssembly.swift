import Data
import Domain
import AwaNetwork
import Foundation
import Swinject
import SwiftData

struct DataAssembly: Assembly {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func assemble(container: Container) {
        registerSchedulingDataSources(in: container)

        container.register(ZoneRepository.self) { resolver in
            DefaultZoneRepository(
                zoneDataSource: Self.resolve(LocalZoneDataSource.self, from: resolver),
                templateDataSource: Self.resolve(LocalTemplateDataSource.self, from: resolver),
                templateOverrideDataSource: Self.resolve(
                    LocalTemplateOverrideDataSource.self,
                    from: resolver
                ),
                profileDataSource: Self.resolve(
                    LocalUserProfileDataSource.self,
                    from: resolver
                ),
                remoteDataSource: Self.resolve(
                    RemoteZoneDataSourceProtocol.self,
                    from: resolver
                )
            )
        }
        container.register(TaskRepository.self) { resolver in
            DefaultTaskRepository(
                localDataSource: Self.resolve(LocalTaskDataSource.self, from: resolver),
                localSessionDataSource: Self.resolve(
                    LocalSessionDataSource.self,
                    from: resolver
                ),
                localProfileDataSource: Self.resolve(
                    LocalUserProfileDataSource.self,
                    from: resolver
                ),
                remoteTaskDataSource: Self.resolve(
                    RemoteTaskDataSource.self,
                    from: resolver
                )
            )
        }
        container.register(GoalRepository.self) { resolver in
            DefaultGoalRepository(
                localDataSource: Self.resolve(LocalGoalDataSource.self, from: resolver)
            )
        }
        container.register(SessionRepository.self) { resolver in
            DefaultSessionRepository(
                localDataSource: Self.resolve(LocalSessionDataSource.self, from: resolver),
                localTaskDataSource: Self.resolve(LocalTaskDataSource.self, from: resolver),
                localProfileDataSource: Self.resolve(
                    LocalUserProfileDataSource.self,
                    from: resolver
                ),
                remoteDataSource: Self.resolve(
                    RemoteSessionDataSourceProtocol.self,
                    from: resolver
                )
            )
        }
        container.register(RemoteTemplateDataSourceProtocol.self) { resolver in
            RemoteTemplateDataSource(
                networkService: Self.resolve(NetworkServiceProtocol.self, from: resolver)
            )
        }
        container.register(TemplateRepository.self) { resolver in
            DefaultTemplateRepository(
                remoteDataSource: Self.resolve(RemoteTemplateDataSourceProtocol.self, from: resolver),
                localDataSource: Self.resolve(LocalTemplateDataSource.self, from: resolver)
            )
        }

        container.register(UserProfileRepository.self) { resolver in
            DefaultUserProfileRepository(
                localDataSource: Self.resolve(
                    LocalUserProfileDataSource.self,
                    from: resolver
                ),
                remoteDataSource: Self.resolve(RemoteProfileDataSource.self, from: resolver)
            )
        }
        .inObjectScope(.container)
        
        container.register(NetworkServiceProtocol.self) { _ in
            NetworkClient.shared
        }
        .inObjectScope(.container)

        registerRemoteDataSources(in: container)

        container.register(AuthSessionDataSource.self) { _ in
            LocalAuthSessionDataSource()
        }
        .inObjectScope(.container)

        container.register(AuthDataSource.self) { resolver in
            RemoteAuthDataSource(
                networkService: Self.resolve(NetworkServiceProtocol.self, from: resolver)
            )
        }
        .inObjectScope(.container)

        container.register(AuthRepository.self) { resolver in
            AuthRepositoryImpl(
                remoteDataSource: Self.resolve(AuthDataSource.self, from: resolver),
                sessionDataSource: Self.resolve(AuthSessionDataSource.self, from: resolver)
            )
        }
        .inObjectScope(.container)

        container.register(OnboardingDataSourceProtocol.self) { resolver in
            OnboardingDataSource(
                networkService: Self.resolve(NetworkServiceProtocol.self, from: resolver)
            )
        }
        .inObjectScope(.container)

        container.register(OnboardingRepositoryProtocol.self) { resolver in
            OnboardingRepository(
                remoteDataSource: Self.resolve(OnboardingDataSourceProtocol.self, from: resolver),
                authSessionDataSource: Self.resolve(AuthSessionDataSource.self, from: resolver)
            )
        }
        .inObjectScope(.container)
    }

    private func registerSchedulingDataSources(in container: Container) {
        container.register(LocalTaskDataSource.self) { _ in
            SwiftDataTaskDataSource(modelContainer: modelContainer)
        }
        .inObjectScope(.container)
        container.register(LocalGoalDataSource.self) { _ in
            SwiftDataGoalDataSource(modelContainer: modelContainer)
        }
        .inObjectScope(.container)
        container.register(LocalSessionDataSource.self) { _ in
            SwiftDataSessionDataSource(modelContainer: modelContainer)
        }
        .inObjectScope(.container)
        container.register(LocalZoneDataSource.self) { _ in
            SwiftDataZoneDataSource(modelContainer: modelContainer)
        }
        .inObjectScope(.container)
        container.register(LocalTemplateDataSource.self) { _ in
            SwiftDataTemplateDataSource(modelContainer: modelContainer)
        }
        .inObjectScope(.container)
        container.register(LocalTemplateOverrideDataSource.self) { _ in
            SwiftDataTemplateOverrideDataSource(modelContainer: modelContainer)
        }
        .inObjectScope(.container)
        container.register(LocalUserProfileDataSource.self) { _ in
            SwiftDataUserProfileDataSource(modelContainer: modelContainer)
        }
        .inObjectScope(.container)
    }

    private func registerRemoteDataSources(in container: Container) {
        container.register(RemoteProfileDataSource.self) { resolver in
            DefaultRemoteProfileDataSource(
                networkService: Self.resolve(NetworkServiceProtocol.self, from: resolver)
            )
        }
        container.register(RemoteGoalDataSource.self) { resolver in
            DefaultRemoteGoalDataSource(
                networkService: Self.resolve(NetworkServiceProtocol.self, from: resolver)
            )
        }
        container.register(RemoteTaskDataSource.self) { resolver in
            DefaultRemoteTaskDataSource(
                networkService: Self.resolve(NetworkServiceProtocol.self, from: resolver)
            )
        }
        container.register(RemoteSessionDataSourceProtocol.self) { resolver in
            RemoteSessionDataSource(
                networkService: Self.resolve(NetworkServiceProtocol.self, from: resolver)
            )
        }
        container.register(RemoteZoneDataSourceProtocol.self) { resolver in
            RemoteZoneDataSource(
                networkService: Self.resolve(NetworkServiceProtocol.self, from: resolver)
            )
        }
    }

    private static func resolve<Service>(
        _ serviceType: Service.Type,
        from resolver: Resolver
    ) -> Service {
        guard let service = resolver.resolve(serviceType) else {
            preconditionFailure("Missing Data registration for \(serviceType)")
        }
        return service
    }
}

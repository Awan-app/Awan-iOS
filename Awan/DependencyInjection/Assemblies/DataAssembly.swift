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
                remoteTemplateDataSource: Self.resolve(
                    RemoteTemplateDataSourceProtocol.self,
                    from: resolver
                ),
                remoteTemplateOverrideDataSource: Self.resolve(
                    RemoteTemplateOverrideDataSourceProtocol.self,
                    from: resolver
                )
            )
        }
        container.register(CategoryRepository.self) { resolver in
            DefaultCategoryRepository(
                localDataSource: Self.resolve(LocalCategoryDataSource.self, from: resolver),
                remoteDataSource: Self.resolve(RemoteCategoryDataSource.self, from: resolver)
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
                ),
                remoteGoalDataSource: Self.resolve(
                    RemoteGoalDataSource.self,
                    from: resolver
                ),
                remoteSessionDataSource: Self.resolve(
                    RemoteSessionDataSourceProtocol.self,
                    from: resolver
                )
            )
        }
        container.register(GoalRepository.self) { resolver in
            DefaultGoalRepository(
                localDataSource: Self.resolve(LocalGoalDataSource.self, from: resolver),
                remoteDataSource: Self.resolve(
                    RemoteGoalDataSource.self,
                    from: resolver
                ),
                remoteTaskDataSource: Self.resolve(
                    RemoteTaskDataSource.self,
                    from: resolver
                ),
                localTaskDataSource: Self.resolve(LocalTaskDataSource.self, from: resolver)
            )
        }

        container.register(GoalDecompositionRepository.self) { resolver in
            DefaultGoalDecompositionRepository(
                remoteDataSource: Self.resolve(
                    RemoteGoalDecompositionDataSource.self,
                    from: resolver
                ),
                localProfileDataSource: Self.resolve(
                    LocalUserProfileDataSource.self,
                    from: resolver
                )
            )
        }
        .inObjectScope(.container)
        container.register(SessionRepository.self) { resolver in
            DefaultSessionRepository(
                localDataSource: Self.resolve(LocalSessionDataSource.self, from: resolver),
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
        container.register(RemoteTemplateOverrideDataSourceProtocol.self) { resolver in
            RemoteTemplateOverrideDataSource(
                networkService: Self.resolve(NetworkServiceProtocol.self, from: resolver)
            )
        }
        container.register(TemplateRepository.self) { resolver in
            DefaultTemplateRepository(
                remoteDataSource: Self.resolve(RemoteTemplateDataSourceProtocol.self, from: resolver),
                localDataSource: Self.resolve(LocalTemplateDataSource.self, from: resolver)
            )
        }
        container.register(TemplateOverrideRepository.self) { resolver in
            DefaultTemplateOverrideRepository(
                remoteDataSource: Self.resolve(RemoteTemplateOverrideDataSourceProtocol.self, from: resolver),
                localDataSource: Self.resolve(LocalTemplateOverrideDataSource.self, from: resolver)
            )
        }
        container.register(RemoteGamificationDataSource.self) { resolver in
            DefaultRemoteGamificationDataSource(
                networkService: Self.resolve(
                    NetworkServiceProtocol.self,
                    from: resolver
                )
            )
        }
        container.register(GamificationRepository.self) { resolver in
            DefaultGamificationRepository(
                remoteDataSource: Self.resolve(
                    RemoteGamificationDataSource.self,
                    from: resolver
                ),
                localGamificationDataSource: Self.resolve(
                    LocalGamificationDataSource.self,
                    from: resolver
                ),
                localProfileDataSource: Self.resolve(
                    LocalUserProfileDataSource.self,
                    from: resolver
                )
            )
        }
        .inObjectScope(.container)
        container.register(UserProfileRepository.self) { resolver in
            DefaultUserProfileRepository(
                localDataSource: Self.resolve(
                    LocalUserProfileDataSource.self,
                    from: resolver
                ),
                remoteDataSource: Self.resolve(RemoteProfileDataSource.self, from: resolver),
                remoteGamificationDataSource: Self.resolve(
                    RemoteGamificationDataSource.self,
                    from: resolver
                )
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

        container.register(LocalDataWiper.self) { [self] _ in
            SwiftDataLocalDataWiper(modelContainer: self.modelContainer)
        }
        .inObjectScope(.container)

        container.register(AuthRepository.self) { resolver in
            AuthRepositoryImpl(
                remoteDataSource: Self.resolve(AuthDataSource.self, from: resolver),
                sessionDataSource: Self.resolve(AuthSessionDataSource.self, from: resolver),
                localDataWiper: Self.resolve(LocalDataWiper.self, from: resolver)
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

        container.register(AiTaskRemoteDataSource.self) { resolver in
            DefaultAiTaskRemoteDataSource(
                networkService: Self.resolve(NetworkServiceProtocol.self, from: resolver)
            )
        }

        container.register(AiTaskRepository.self) { resolver in
            DefaultAiTaskRepository(
                remoteDataSource: Self.resolve(AiTaskRemoteDataSource.self, from: resolver),
                remoteGoalDataSource: Self.resolve(RemoteGoalDataSource.self, from: resolver),
                localTaskDataSource: Self.resolve(LocalTaskDataSource.self, from: resolver),
                localSessionDataSource: Self.resolve(LocalSessionDataSource.self, from: resolver)
            )
        }
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
        container.register(LocalCategoryDataSource.self) { _ in
            SwiftDataCategoryDataSource(modelContainer: modelContainer)
        }
        .inObjectScope(.container)
        container.register(LocalGamificationDataSource.self) { _ in
            SwiftDataGamificationDataSource(modelContainer: modelContainer)
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
        container.register(RemoteGoalDecompositionDataSource.self) { resolver in
            DefaultRemoteGoalDecompositionDataSource(
                networkService: Self.resolve(
                    NetworkServiceProtocol.self,
                    from: resolver
                )
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
        container.register(RemoteCategoryDataSource.self) { resolver in
            DefaultRemoteCategoryDataSource(
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

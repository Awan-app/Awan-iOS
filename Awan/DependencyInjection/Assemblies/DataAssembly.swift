import Data
import Domain
import AwaNetwork
import Foundation
import Swinject
import SwiftData

enum SchedulingDataSourceImplementation {
    case swiftData
    case inMemory(SchedulingMockData)
}

struct DataAssembly: Assembly {
    private let modelContainer: ModelContainer?
    private let schedulingImplementation: SchedulingDataSourceImplementation

    init(
        modelContainer: ModelContainer? = nil,
        schedulingImplementation: SchedulingDataSourceImplementation = .swiftData
    ) {
        self.modelContainer = modelContainer
        self.schedulingImplementation = schedulingImplementation
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
                )
            )
        }
        container.register(TaskRepository.self) { resolver in
            DefaultTaskRepository(
                localDataSource: Self.resolve(LocalTaskDataSource.self, from: resolver)
            )
        }
        container.register(GoalRepository.self) { resolver in
            DefaultGoalRepository(
                localDataSource: Self.resolve(LocalGoalDataSource.self, from: resolver)
            )
        }
        container.register(SessionRepository.self) { resolver in
            DefaultSessionRepository(
                localDataSource: Self.resolve(LocalSessionDataSource.self, from: resolver)
            )
        }
        
        container.register(NetworkServiceProtocol.self) { _ in
            NetworkClient.shared
        }
        .inObjectScope(.container)

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
                remoteDataSource: Self.resolve(OnboardingDataSourceProtocol.self, from: resolver)
            )
        }
        .inObjectScope(.container)
    }

    private func registerSchedulingDataSources(in container: Container) {
        switch schedulingImplementation {
        case .swiftData:
            guard let modelContainer else {
                preconditionFailure("SwiftData scheduling requires a ModelContainer")
            }
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

        case .inMemory(let data):
            let sources = InMemorySchedulingDataSources(data: data)
            container.register(LocalTaskDataSource.self) { _ in sources.task }
                .inObjectScope(.container)
            container.register(LocalGoalDataSource.self) { _ in sources.goal }
                .inObjectScope(.container)
            container.register(LocalSessionDataSource.self) { _ in sources.session }
                .inObjectScope(.container)
            container.register(LocalZoneDataSource.self) { _ in sources.zone }
                .inObjectScope(.container)
            container.register(LocalTemplateDataSource.self) { _ in sources.template }
                .inObjectScope(.container)
            container.register(LocalTemplateOverrideDataSource.self) { _ in sources.templateOverride }
                .inObjectScope(.container)
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

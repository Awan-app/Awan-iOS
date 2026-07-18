import Data
import Domain
import AwaNetwork
import Swinject

struct DataAssembly: Assembly {
    func assemble(container: Container) {
        container.register(InMemoryScheduleDataSource.self) { _ in
            InMemoryScheduleDataSource()
        }
        .inObjectScope(.container)

        container.register(LocalZoneDataSource.self) { resolver in
            Self.resolve(InMemoryScheduleDataSource.self, from: resolver)
        }
        .inObjectScope(.container)

        container.register(ZoneRepository.self) { resolver in
            guard let dataSource = resolver.resolve(LocalZoneDataSource.self) else {
                preconditionFailure("LocalZoneDataSource must be registered before ZoneRepository")
            }
            return DefaultZoneRepository(localDataSource: dataSource)
        }
        container.register(TaskRepository.self) { resolver in
            DefaultTaskRepository(
                store: Self.resolve(InMemoryScheduleDataSource.self, from: resolver)
            )
        }
        container.register(GoalRepository.self) { resolver in
            DefaultGoalRepository(
                store: Self.resolve(InMemoryScheduleDataSource.self, from: resolver)
            )
        }
        container.register(SessionRepository.self) { resolver in
            DefaultSessionRepository(
                store: Self.resolve(InMemoryScheduleDataSource.self, from: resolver)
            )
        }
        
        container.register(NetworkServiceProtocol.self) { _ in
            NetworkClient.shared
        }
        .inObjectScope(.container)
        
        container.register(AuthDataSource.self) { resolver in
            RemoteAuthDataSource(
                networkService: Self.resolve(NetworkServiceProtocol.self, from: resolver)
            )
        }
        
        container.register(AuthRepository.self) { resolver in
            AuthRepositoryImpl(
                remoteDataSource: Self.resolve(AuthDataSource.self, from: resolver)
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

import Data
import Domain
import Swinject

struct DataAssembly: Assembly {
    func assemble(container: Container) {
        container.register(LocalZoneDataSource.self) { _ in
            FixedZoneDataSource()
        }

        container.register(ZoneRepository.self) { resolver in
            guard let dataSource = resolver.resolve(LocalZoneDataSource.self) else {
                preconditionFailure("LocalZoneDataSource must be registered before ZoneRepository")
            }
            return DefaultZoneRepository(localDataSource: dataSource)
        }
    }
}

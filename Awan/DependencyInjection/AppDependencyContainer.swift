import Swinject
import Data
import SwiftData

final class AppDependencyContainer {
    static let shared = AppDependencyContainer(modelContainer: makeSchedulingModelContainer())
    let resolver: Resolver

    init(modelContainer: ModelContainer) {
        let assembler = Assembler([
            DataAssembly(modelContainer: modelContainer),
            DomainAssembly(),
            PresentationAssembly(),
        ])
        resolver = assembler.resolver
    }

    func resolve<Service>(_ serviceType: Service.Type) -> Service {
        guard let service = resolver.resolve(serviceType) else {
            preconditionFailure("Missing app dependency for \(serviceType)")
        }
        return service
    }

    func resolve<Service, Arg1>(_ serviceType: Service.Type, argument: Arg1) -> Service {
        guard let service = resolver.resolve(serviceType, argument: argument) else {
            preconditionFailure("Missing app dependency for \(serviceType) with argument \(Arg1.self)")
        }
        return service
    }
    private static func makeSchedulingModelContainer() -> ModelContainer {
        let schema = SchedulingPersistence.schema
        let configuration = ModelConfiguration(
            "AwanScheduling",
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .none,
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create scheduling ModelContainer: \(error)")
        }
    }
}

import Swinject

final class AppDependencyContainer {
    let resolver: Resolver

    init() {
        let assembler = Assembler([
            DataAssembly(),
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
}

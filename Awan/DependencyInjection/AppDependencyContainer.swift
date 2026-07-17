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
}

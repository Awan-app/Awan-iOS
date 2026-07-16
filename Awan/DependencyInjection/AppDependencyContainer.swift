import Swinject

final class AppDependencyContainer {
    let resolver: Resolver

    init() {
        let assembler = Assembler([
            DataAssembly(),
            DomainAssembly(),
        ])
        resolver = assembler.resolver
    }
}

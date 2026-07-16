import Domain
import Swinject

struct DomainAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ZoneWindowResolving.self) { _ in
            CalendarZoneWindowResolver()
        }
        container.register(AvailabilityCalculating.self) { _ in
            DefaultAvailabilityCalculator()
        }
        container.register(TaskDependencyOrdering.self) { _ in
            StableTaskDependencySorter()
        }
        container.register(ResolutionCandidateGenerating.self) { resolver in
            DefaultResolutionCandidateGenerator(
                zoneWindowResolver: Self.resolve(ZoneWindowResolving.self, from: resolver),
                availabilityCalculator: Self.resolve(AvailabilityCalculating.self, from: resolver)
            )
        }
        container.register(ScheduleEngine.self) { resolver in
            DefaultScheduleEngine(
                dependencyOrdering: Self.resolve(TaskDependencyOrdering.self, from: resolver),
                zoneWindowResolver: Self.resolve(ZoneWindowResolving.self, from: resolver),
                availabilityCalculator: Self.resolve(AvailabilityCalculating.self, from: resolver),
                resolutionCandidateGenerator: Self.resolve(
                    ResolutionCandidateGenerating.self,
                    from: resolver
                )
            )
        }
        container.register(FetchZonesUseCase.self) { resolver in
            DefaultFetchZonesUseCase(
                repository: Self.resolve(ZoneRepository.self, from: resolver)
            )
        }
    }

    private static func resolve<Service>(
        _ serviceType: Service.Type,
        from resolver: Resolver
    ) -> Service {
        guard let service = resolver.resolve(serviceType) else {
            preconditionFailure("Missing DI registration for \(serviceType)")
        }
        return service
    }
}

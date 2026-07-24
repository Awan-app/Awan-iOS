import Domain
import Swinject

struct DomainAssembly: Assembly {
    func assemble(container: Container) {
        registerServices(in: container)
        registerCoreUseCases(in: container)
        registerConflictUseCases(in: container)
        registerSimulationUseCases(in: container)
    }

    private func registerServices(in container: Container) {
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
        container.register(ScheduleWorkspaceProviding.self) { resolver in
            DefaultScheduleWorkspaceProvider(
                zoneRepository: Self.resolve(ZoneRepository.self, from: resolver),
                goalRepository: Self.resolve(GoalRepository.self, from: resolver),
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(TaskScheduleReconciling.self) { resolver in
            DefaultTaskScheduleReconciler(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver),
                engine: Self.resolve(ScheduleEngine.self, from: resolver),
                zoneWindowResolver: Self.resolve(ZoneWindowResolving.self, from: resolver)
            )
        }
    }

    private func registerCoreUseCases(in container: Container) {
        container.register(FetchZonesUseCase.self) { resolver in
            DefaultFetchZonesUseCase(
                repository: Self.resolve(ZoneRepository.self, from: resolver)
            )
        }
        container.register(FetchTasksUseCase.self) { resolver in
            DefaultFetchTasksUseCase(
                repository: Self.resolve(TaskRepository.self, from: resolver)
            )
        }
        container.register(FetchSessionsUseCase.self) { resolver in
            DefaultFetchSessionsUseCase(
                repository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(GetUserProfileUseCase.self) { resolver in
            DefaultGetUserProfileUseCase(
                repository: Self.resolve(UserProfileRepository.self, from: resolver)
            )
        }
        container.register(RescheduleSessionUseCase.self) { resolver in
            DefaultRescheduleSessionUseCase(
                repository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(SetSessionLockUseCase.self) { resolver in
            DefaultSetSessionLockUseCase(
                repository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(SetSessionCompletionUseCase.self) { resolver in
            DefaultSetSessionCompletionUseCase(
                repository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(DeleteSessionUseCase.self) { resolver in
            DefaultDeleteSessionUseCase(
                repository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(LoadScheduleWorkspaceUseCase.self) { resolver in
            DefaultLoadScheduleWorkspaceUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver)
            )
        }
        container.register(CreateTaskUseCase.self) { resolver in
            DefaultCreateTaskUseCase(
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                reconciler: Self.resolve(TaskScheduleReconciling.self, from: resolver)
            )
        }
        container.register(UpdateTaskUseCase.self) { resolver in
            DefaultUpdateTaskUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver),
                reconciler: Self.resolve(TaskScheduleReconciling.self, from: resolver)
            )
        }
        container.register(DeleteTaskUseCase.self) { resolver in
            DefaultDeleteTaskUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(CreateSevenTaskGoalUseCase.self) { resolver in
            DefaultCreateSevenTaskGoalUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                goalRepository: Self.resolve(GoalRepository.self, from: resolver),
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver),
                engine: Self.resolve(ScheduleEngine.self, from: resolver)
            )
        }
        container.register(MoveSessionUseCase.self) { resolver in
            DefaultMoveSessionUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(RequestOTPUseCase.self) { resolver in
            DefaultRequestOTPUseCase(
                repository: Self.resolve(AuthRepository.self, from: resolver)
            )
        }
        container.register(VerifyOTPUseCase.self) { resolver in
            VerifyOTPUseCase(
                repository: Self.resolve(AuthRepository.self, from: resolver)
            )
        }
        container.register(ObserveAuthenticationUseCase.self) { resolver in
            ObserveAuthenticationUseCase(
                repository: Self.resolve(AuthRepository.self, from: resolver)
            )
        }
        container.register(LogoutUseCase.self) { resolver in
            LogoutUseCase(
                repository: Self.resolve(AuthRepository.self, from: resolver)
            )
        }
        container.register(CompleteOnboardingUseCase.self) { resolver in
            DefaultCompleteOnboardingUseCase(
                repository: Self.resolve(OnboardingRepositoryProtocol.self, from: resolver)
            )
        }
    }

    private func registerConflictUseCases(in container: Container) {
        container.register(ApplyScheduleCandidateUseCase.self) { resolver in
            DefaultApplyScheduleCandidateUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(SeparateOverlappingSessionsUseCase.self) { resolver in
            DefaultSeparateOverlappingSessionsUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(MoveOverlappingSessionUseCase.self) { resolver in
            DefaultMoveOverlappingSessionUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(ShiftGoalDependencyChainUseCase.self) { resolver in
            DefaultShiftGoalDependencyChainUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                goalRepository: Self.resolve(GoalRepository.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(StackDependentTasksUseCase.self) { resolver in
            DefaultStackDependentTasksUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(MakeTaskIndependentUseCase.self) { resolver in
            DefaultMakeTaskIndependentUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                taskRepository: Self.resolve(TaskRepository.self, from: resolver)
            )
        }
        container.register(ReplanZoneSessionsUseCase.self) { resolver in
            DefaultReplanZoneSessionsUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver),
                zoneWindowResolver: Self.resolve(ZoneWindowResolving.self, from: resolver)
            )
        }
        container.register(RestoreZoneUseCase.self) { resolver in
            DefaultRestoreZoneUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                zoneRepository: Self.resolve(ZoneRepository.self, from: resolver)
            )
        }
        container.register(KeepFixedOverAllocationUseCase.self) { resolver in
            DefaultKeepFixedOverAllocationUseCase(
                reconciler: Self.resolve(TaskScheduleReconciling.self, from: resolver)
            )
        }
        container.register(TrimFixedOverAllocationUseCase.self) { resolver in
            DefaultTrimFixedOverAllocationUseCase(
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver),
                reconciler: Self.resolve(TaskScheduleReconciling.self, from: resolver)
            )
        }
        container.register(KeepFixedSessionsOutsideZoneUseCase.self) { resolver in
            DefaultKeepFixedSessionsOutsideZoneUseCase(
                reconciler: Self.resolve(TaskScheduleReconciling.self, from: resolver)
            )
        }
        container.register(MoveFixedSessionsIntoZoneUseCase.self) { resolver in
            DefaultMoveFixedSessionsIntoZoneUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver),
                zoneWindowResolver: Self.resolve(ZoneWindowResolving.self, from: resolver),
                availabilityCalculator: Self.resolve(AvailabilityCalculating.self, from: resolver),
                reconciler: Self.resolve(TaskScheduleReconciling.self, from: resolver)
            )
        }
        container.register(RestoreTaskZoneUseCase.self) { resolver in
            DefaultRestoreTaskZoneUseCase(
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver),
                reconciler: Self.resolve(TaskScheduleReconciling.self, from: resolver)
            )
        }
    }

    private func registerSimulationUseCases(in container: Container) {
        container.register(ResetScheduleSimulationUseCase.self) { resolver in
            DefaultResetScheduleSimulationUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                goalRepository: Self.resolve(GoalRepository.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(SimulateScheduleScenarioUseCase.self) { resolver in
            DefaultSimulateScheduleScenarioUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                zoneRepository: Self.resolve(ZoneRepository.self, from: resolver),
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver),
                engine: Self.resolve(ScheduleEngine.self, from: resolver),
                createGoalUseCase: Self.resolve(CreateSevenTaskGoalUseCase.self, from: resolver),
                resetUseCase: Self.resolve(ResetScheduleSimulationUseCase.self, from: resolver)
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

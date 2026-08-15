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
        container.register(FetchCategoriesUseCase.self) { resolver in
            DefaultFetchCategoriesUseCase(
                repository: Self.resolve(CategoryRepository.self, from: resolver)
            )
        }
        container.register(CreateCategoryUseCase.self) { resolver in
            DefaultCreateCategoryUseCase(
                repository: Self.resolve(CategoryRepository.self, from: resolver)
            )
        }
        container.register(FetchTasksUseCase.self) { resolver in
            DefaultFetchTasksUseCase(
                repository: Self.resolve(TaskRepository.self, from: resolver)
            )
        }
        container.register(FetchGoalsUseCase.self) { resolver in
            DefaultFetchGoalsUseCase(
                repository: Self.resolve(GoalRepository.self, from: resolver)
            )
        }
        container.register(FetchGoalTasksUseCase.self) { resolver in
            DefaultFetchGoalTasksUseCase(
                repository: Self.resolve(GoalRepository.self, from: resolver)
            )
        }
        container.register(FetchSessionsUseCase.self) { resolver in
            DefaultFetchSessionsUseCase(
                repository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(FetchInboxTasksUseCase.self) { resolver in
            DefaultFetchInboxTasksUseCase(
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(FetchGoalsWithTasksUseCase.self) { resolver in
            DefaultFetchGoalsWithTasksUseCase(
                goalRepository: Self.resolve(GoalRepository.self, from: resolver),
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(DefaultFetchInboxTasksUseCase.self) { resolver in
            DefaultFetchInboxTasksUseCase(
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(SetTaskCompletionUseCase.self) { resolver in
            DefaultSetTaskCompletionUseCase(
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                userProfileRepository: Self.resolve(
                    UserProfileRepository.self,
                    from: resolver
                )
            )
        }
        container.register(DeleteInboxTaskUseCase.self) { resolver in
            DefaultDeleteInboxTaskUseCase(
                taskRepository: Self.resolve(TaskRepository.self, from: resolver)
            )
        }
        container.register(GetUserProfileUseCase.self) { resolver in
            DefaultGetUserProfileUseCase(
                repository: Self.resolve(UserProfileRepository.self, from: resolver)
            )
        }
        container.register(FetchMCPConnectionDetailsUseCase.self) { resolver in
            DefaultFetchMCPConnectionDetailsUseCase(
                repository: Self.resolve(UserProfileRepository.self, from: resolver)
            )
        }
        container.register(FetchDailyWheelUseCase.self) { resolver in
            DefaultFetchDailyWheelUseCase(
                repository: Self.resolve(GamificationRepository.self, from: resolver)
            )
        }
        container.register(SpinDailyWheelUseCase.self) { resolver in
            DefaultSpinDailyWheelUseCase(
                repository: Self.resolve(GamificationRepository.self, from: resolver)
            )
        }
        container.register(FetchActivityDaysUseCase.self) { resolver in
            DefaultFetchActivityDaysUseCase(
                repository: Self.resolve(GamificationRepository.self, from: resolver)
            )
        }
        container.register(UpdateUserProfileUseCase.self) { resolver in
            DefaultUpdateUserProfileUseCase(
                repository: Self.resolve(UserProfileRepository.self, from: resolver)
            )
        }
        container.register(UpdateProfilePictureUseCase.self) { resolver in
            DefaultUpdateProfilePictureUseCase(
                repository: Self.resolve(UserProfileRepository.self, from: resolver)
            )
        }

        container.register(UpdateSessionDurationUseCase.self) { resolver in
            DefaultUpdateSessionDurationUseCase(
                repository: Self.resolve(UserProfileRepository.self, from: resolver)
            )
        }
        container.register(UpdateTimezoneUseCase.self) { resolver in
            DefaultUpdateTimezoneUseCase(
                repository: Self.resolve(UserProfileRepository.self, from: resolver)
            )
        }
        container.register(UpdateSleepScheduleUseCase.self) { resolver in
            DefaultUpdateSleepScheduleUseCase(
                repository: Self.resolve(UserProfileRepository.self, from: resolver)
            )
        }
        container.register(RescheduleSessionUseCase.self) { resolver in
            DefaultRescheduleSessionUseCase(
                repository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(UpdateSessionScheduleUseCase.self) { resolver in
            DefaultUpdateSessionScheduleUseCase(
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
                sessionRepository: Self.resolve(
                    SessionRepository.self,
                    from: resolver
                ),
                taskRepository: Self.resolve(
                    TaskRepository.self,
                    from: resolver
                ),
                userProfileRepository: Self.resolve(
                    UserProfileRepository.self,
                    from: resolver
                )
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
                workspaceProvider: Self.resolve(
                    ScheduleWorkspaceProviding.self,
                    from: resolver
                )
            )
        }
        container.register(CreateAITaskUseCase.self) { resolver in
            DefaultCreateAITaskUseCase(
                repository: Self.resolve(AiTaskRepository.self, from: resolver)
            )
        }
        container.register(ImageToTasksUseCase.self) { resolver in
            DefaultImageToTasksUseCase(
                repository: Self.resolve(AiTaskRepository.self, from: resolver)
            )
        }
        container.register(AcceptProposedTaskUseCase.self) { resolver in
            DefaultAcceptProposedTaskUseCase(
                repository: Self.resolve(AiTaskRepository.self, from: resolver)
            )
        }
        container.register(AcceptProposedTasksUseCase.self) { resolver in
            DefaultAcceptProposedTasksUseCase(
                repository: Self.resolve(AiTaskRepository.self, from: resolver)
            )
        }
        container.register(UpdateTaskUseCase.self) { resolver in
            DefaultUpdateTaskUseCase(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                taskRepository: Self.resolve(TaskRepository.self, from: resolver)
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
        container.register(CreateEmptyGoalUseCase.self) { resolver in
            DefaultCreateEmptyGoalUseCase(
                repository: Self.resolve(GoalRepository.self, from: resolver)
            )
        }
        container.register(AddTaskToGoalUseCase.self) { resolver in
            DefaultAddTaskToGoalUseCase(
                repository: Self.resolve(GoalRepository.self, from: resolver)
            )
        }
        container.register(UpdateGoalUseCase.self) { resolver in
            DefaultUpdateGoalUseCase(
                repository: Self.resolve(GoalRepository.self, from: resolver)
            )
        }
        container.register(DeleteGoalUseCase.self) { resolver in
            DefaultDeleteGoalUseCase(
                repository: Self.resolve(GoalRepository.self, from: resolver)
            )
        }

        container.register(SendGoalDecompositionMessageUseCase.self) { resolver in
            DefaultSendGoalDecompositionMessageUseCase(
                repository: Self.resolve(
                    GoalDecompositionRepository.self,
                    from: resolver
                )
            )
        }
        container.register(ConfirmGoalProposalUseCase.self) { resolver in
            DefaultConfirmGoalProposalUseCase(
                repository: Self.resolve(
                    GoalDecompositionRepository.self,
                    from: resolver
                )
            )
        }
        container.register(RequestGoalScheduleProposalUseCase.self) { resolver in
            DefaultRequestGoalScheduleProposalUseCase(
                repository: Self.resolve(
                    GoalDecompositionRepository.self,
                    from: resolver
                )
            )
        }
        container.register(ConfirmGoalScheduleUseCase.self) { resolver in
            DefaultConfirmGoalScheduleUseCase(
                repository: Self.resolve(
                    GoalDecompositionRepository.self,
                    from: resolver
                )
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
        container.register(GoogleSignInUseCase.self) { resolver in
            DefaultGoogleSignInUseCase(
                authRepository: Self.resolve(AuthRepository.self, from: resolver)
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
            CompleteOnboardingUseCaseImpl(
                repository: Self.resolve(OnboardingRepositoryProtocol.self, from: resolver)
            )
        }
        container.register(CreateOnboardingTemplateUseCase.self) { resolver in
            CreateOnboardingTemplateUseCaseImpl(
                templateRepository: Self.resolve(TemplateRepository.self, from: resolver)
            )
        }
        container.register(FetchTemplatesUseCase.self) { resolver in
            DefaultFetchTemplatesUseCase(
                repository: Self.resolve(TemplateRepository.self, from: resolver)
            )
        }
        container.register(FetchTemplateOverridesUseCase.self) { resolver in
            DefaultFetchTemplateOverridesUseCase(
                repository: Self.resolve(TemplateOverrideRepository.self, from: resolver)
            )
        }
        container.register(CreateTemplateUseCase.self) { resolver in
            DefaultCreateTemplateUseCase(
                repository: Self.resolve(TemplateRepository.self, from: resolver)
            )
        }
        container.register(UpdateTemplateUseCase.self) { resolver in
            DefaultBulkUpdateTemplateUseCase(
                repository: Self.resolve(TemplateRepository.self, from: resolver)
            )
        }
        container.register(UpdateTemplateDetailsUseCase.self) { resolver in
            DefaultUpdateTemplateDetailsUseCase(
                repository: Self.resolve(TemplateRepository.self, from: resolver)
            )
        }
        container.register(UpdateBulkTemplateOverrideUseCase.self) { resolver in
            DefaultUpdateBulkTemplateOverrideUseCase(
                repository: Self.resolve(TemplateOverrideRepository.self, from: resolver)
            )
        }
        container.register(DeleteTemplateOverrideUseCase.self) { resolver in
            DefaultDeleteTemplateOverrideUseCase(
                repository: Self.resolve(TemplateOverrideRepository.self, from: resolver)
            )
        }
        container.register(CreateTemplateOverrideUseCase.self) { resolver in
            DefaultCreateTemplateOverrideUseCase(
                repository: Self.resolve(TemplateOverrideRepository.self, from: resolver)
            )
        }
        container.register(UpdateTemplateOverrideUseCase.self) { resolver in
            DefaultUpdateTemplateOverrideUseCase(
                repository: Self.resolve(TemplateOverrideRepository.self, from: resolver)
            )
        }
        container.register(DeleteTemplateUseCase.self) { resolver in
            DefaultDeleteTemplateUseCase(
                repository: Self.resolve(TemplateRepository.self, from: resolver)
            )
        }
        container.register(ResolveTemplateWeekdayAvailabilityUseCase.self) { _ in
            DefaultResolveTemplateWeekdayAvailabilityUseCase()
        }
        container.register(ManageZoneScheduleUseCase.self) { _ in
            ManageZoneScheduleUseCaseImpl()
        }
        container.register(ManageDailyZoneScheduleUseCase.self) { _ in
            DefaultManageDailyZoneScheduleUseCase()
        }
        container.register(FetchStoreItemsUseCase.self) { resolver in
            DefaultFetchStoreItemsUseCase(
                repository: Self.resolve(GamificationRepository.self, from: resolver)
            )
        }
        container.register(FetchStorefrontUseCase.self) { resolver in
            DefaultFetchStorefrontUseCase(
                repository: Self.resolve(GamificationRepository.self, from: resolver)
            )
        }
        container.register(BuyStoreItemUseCase.self) { resolver in
            DefaultBuyStoreItemUseCase(
                repository: Self.resolve(GamificationRepository.self, from: resolver)
            )
        }
        container.register(EquipStoreItemUseCase.self) { resolver in
            DefaultEquipStoreItemUseCase(
                repository: Self.resolve(GamificationRepository.self, from: resolver)
            )
        }
        container.register(FetchEquippedItemsUseCase.self) { resolver in
            DefaultFetchEquippedItemsUseCase(
                repository: Self.resolve(GamificationRepository.self, from: resolver)
            )
        }
        container.register(FetchUserPointsUseCase.self) { resolver in
            DefaultFetchUserPointsUseCase(
                repository: Self.resolve(GamificationRepository.self, from: resolver)
            )
        }
        container.register(FetchStoreInventoryUseCase.self) { resolver in
            DefaultFetchStoreInventoryUseCase(
                repository: Self.resolve(GamificationRepository.self, from: resolver)
            )
        }
        container.register(UnequipStoreItemUseCase.self) { resolver in
            DefaultUnequipStoreItemUseCase(
                repository: Self.resolve(GamificationRepository.self, from: resolver)
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
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver),
                reconciler: Self.resolve(TaskScheduleReconciling.self, from: resolver)
            )
        }
    }

    private func registerSimulationUseCases(in container: Container) {
        container.register(ResetScheduleSimulationUseCase.self) { resolver in
            ResetScheduleSimulationUseCaseImpl(
                workspaceProvider: Self.resolve(ScheduleWorkspaceProviding.self, from: resolver),
                taskRepository: Self.resolve(TaskRepository.self, from: resolver),
                goalRepository: Self.resolve(GoalRepository.self, from: resolver),
                sessionRepository: Self.resolve(SessionRepository.self, from: resolver)
            )
        }
        container.register(SimulateScheduleScenarioUseCase.self) { resolver in
            SimulateScheduleScenarioUseCaseImpl(
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

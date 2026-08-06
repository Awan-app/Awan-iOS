import Domain
import Presentation
import Swinject

struct PresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AppCoordinator.self) { _ in
            MainActor.assumeIsolated {
                AppCoordinator()
            }
        }
        .inObjectScope(.container)

        container.register(AuthenticationState.self) { resolver in
            let useCase = Self.resolve(ObserveAuthenticationUseCase.self, from: resolver)
            return MainActor.assumeIsolated {
                AuthenticationState(observeAuthenticationUseCase: useCase)
            }
        }
        .inObjectScope(.container)

        container.register(LoginViewModel.self) { resolver in
            let useCase = Self.resolve(RequestOTPUseCase.self, from: resolver)
            return MainActor.assumeIsolated {
                LoginViewModel(requestOTPUseCase: useCase)
            }
        }

        container.register(OtpVerificationViewModel.self) {
            (resolver, context: OtpVerificationContext) in
            let requestUseCase = Self.resolve(RequestOTPUseCase.self, from: resolver)
            let verifyUseCase = Self.resolve(VerifyOTPUseCase.self, from: resolver)
            return MainActor.assumeIsolated {
                OtpVerificationViewModel(
                    context: context,
                    requestOTPUseCase: requestUseCase,
                    verifyOTPUseCase: verifyUseCase
                )
            }
        }
        container.register(ScheduleTimelineUseCases.self) { resolver in
            ScheduleTimelineUseCases(
                workspace: Self.resolve(LoadScheduleWorkspaceUseCase.self, from: resolver),
                tasks: ScheduleTaskUseCases(
                    create: Self.resolve(CreateTaskUseCase.self, from: resolver),
                    update: Self.resolve(UpdateTaskUseCase.self, from: resolver),
                    delete: Self.resolve(DeleteTaskUseCase.self, from: resolver)
                ),
                goals: ScheduleGoalUseCases(
                    createSevenTaskGoal: Self.resolve(
                        CreateSevenTaskGoalUseCase.self,
                        from: resolver
                    )
                ),
                sessions: ScheduleSessionUseCases(
                    move: Self.resolve(MoveSessionUseCase.self, from: resolver)
                ),
                conflicts: Self.makeConflictUseCases(resolver: resolver),
                simulation: ScheduleSimulationUseCases(
                    simulate: Self.resolve(SimulateScheduleScenarioUseCase.self, from: resolver),
                    reset: Self.resolve(ResetScheduleSimulationUseCase.self, from: resolver)
                )
            )
        }
        container.register(ScheduleTimelineViewModel.self) { resolver in
            let useCases = Self.resolve(ScheduleTimelineUseCases.self, from: resolver)
            return MainActor.assumeIsolated {
                ScheduleTimelineViewModel(useCases: useCases)
            }
        }

        container.register(HomeUseCases.self) { resolver in
            HomeUseCases(
                reads: HomeReadUseCases(
                    tasks: Self.resolve(FetchTasksUseCase.self, from: resolver),
                    sessions: Self.resolve(FetchSessionsUseCase.self, from: resolver),
                    zones: Self.resolve(FetchZonesUseCase.self, from: resolver),
                    userProfile: Self.resolve(GetUserProfileUseCase.self, from: resolver)
                ),
                sessions: HomeSessionUseCases(
                    reschedule: Self.resolve(RescheduleSessionUseCase.self, from: resolver),
                    setLock: Self.resolve(SetSessionLockUseCase.self, from: resolver),
                    setCompletion: Self.resolve(SetSessionCompletionUseCase.self, from: resolver),
                    delete: Self.resolve(DeleteSessionUseCase.self, from: resolver)
                )
            )
        }

        container.register(CreationUseCases.self) { resolver in
            CreationUseCases(
                fetchZones: Self.resolve(FetchZonesUseCase.self, from: resolver),
                createTask: Self.resolve(CreateTaskUseCase.self, from: resolver),
                createAITask: Self.resolve(CreateAITaskUseCase.self, from: resolver),
                imageToTasks: Self.resolve(ImageToTasksUseCase.self, from: resolver),
                acceptProposedTask: Self.resolve(AcceptProposedTaskUseCase.self, from: resolver),
                acceptProposedTasks: Self.resolve(AcceptProposedTasksUseCase.self, from: resolver),
                userProfile: Self.resolve(GetUserProfileUseCase.self, from: resolver),
                goalDecomposition: GoalDecompositionUseCases(
                    sendMessage: Self.resolve(
                        SendGoalDecompositionMessageUseCase.self,
                        from: resolver
                    ),
                    confirmProposal: Self.resolve(
                        ConfirmGoalProposalUseCase.self,
                        from: resolver
                    ),
                    scheduleGoal: Self.resolve(
                        ScheduleCreatedGoalUseCase.self,
                        from: resolver
                    )
                )
            )
        }

        container.register(HomeViewModel.self) { resolver in
            let useCases = Self.resolve(HomeUseCases.self, from: resolver)
            return MainActor.assumeIsolated {
                HomeViewModel(useCases: useCases)
            }
        }
        .inObjectScope(.container)

        container.register(CalendarViewModel.self) { resolver in
            let useCase = Self.resolve(FetchGoalsUseCase.self, from: resolver)
            return MainActor.assumeIsolated {
                CalendarViewModel(fetchGoalsUseCase: useCase)
            }
        }
        .inObjectScope(.container)

        container.register(InboxUseCases.self) { resolver in
            InboxUseCases(
                fetchInboxTasks: Self.resolve(FetchInboxTasksUseCase.self, from: resolver),
                fetchGoals: Self.resolve(FetchGoalsUseCase.self, from: resolver),
                completeTask: Self.resolve(CompleteTaskSessionsUseCase.self, from: resolver),
                deleteInboxTask: Self.resolve(DeleteInboxTaskUseCase.self, from: resolver)
            )
        }

        container.register(GoalsUseCases.self) { resolver in
            GoalsUseCases(
                fetchGoalsWithTasks: Self.resolve(FetchGoalsWithTasksUseCase.self, from: resolver)
            )
        }

        container.register(GoalsViewModel.self) { resolver in
            let useCases = Self.resolve(GoalsUseCases.self, from: resolver)
            let appCoordinator = Self.resolve(AppCoordinator.self, from: resolver)
            return MainActor.assumeIsolated {
                GoalsViewModel(useCases: useCases) { goalID in
                    appCoordinator.mainCoordinator.push(.inboxTaskDetail(goalID))
                }
            }
        }
        .inObjectScope(.container)

        container.register(InboxViewModel.self) { resolver in
            let useCases = Self.resolve(InboxUseCases.self, from: resolver)
            let goalsVM = Self.resolve(GoalsViewModel.self, from: resolver)
            return MainActor.assumeIsolated {
                InboxViewModel(useCases: useCases, goalsViewModel: goalsVM)
            }
        }
        .inObjectScope(.container)

        container.register(OnboardingViewModel.self) { resolver in
            let useCase = Self.resolve(CompleteOnboardingUseCase.self, from: resolver)
            let createTemplateUseCase = Self.resolve(CreateOnboardingTemplateUseCase.self, from: resolver)
            let manageZoneScheduleUseCase = Self.resolve(ManageZoneScheduleUseCase.self, from: resolver)
            return MainActor.assumeIsolated {
                OnboardingViewModel(
                    completeOnboardingUseCase: useCase,
                    createOnboardingTemplateUseCase: createTemplateUseCase,
                    manageZoneScheduleUseCase: manageZoneScheduleUseCase
                )
            }
        }
        .inObjectScope(.container)

        container.register(ProfileViewModel.self) { resolver in
            let useCase = Self.resolve(GetUserProfileUseCase.self, from: resolver)
            let updateSessionDurationUseCase = Self.resolve(UpdateSessionDurationUseCase.self, from: resolver)
            let updateTimezoneUseCase = Self.resolve(UpdateTimezoneUseCase.self, from: resolver)
            let updateSleepScheduleUseCase = Self.resolve(UpdateSleepScheduleUseCase.self, from: resolver)
            let fetchZonesUseCase = Self.resolve(FetchZonesUseCase.self, from: resolver)
            let logoutUseCase = Self.resolve(LogoutUseCase.self, from: resolver)
            return MainActor.assumeIsolated {
                ProfileViewModel(
                    getUserProfileUseCase: useCase,
                    fetchZonesUseCase: fetchZonesUseCase,
                    logoutUseCase: logoutUseCase,
                    updateSessionDurationUseCase: updateSessionDurationUseCase,
                    updateTimezoneUseCase: updateTimezoneUseCase,
                    updateSleepScheduleUseCase: updateSleepScheduleUseCase
                )
            }
        }
        .inObjectScope(.container)

        container.register(UserInfoViewModel.self) { resolver in
            let useCase = Self.resolve(GetUserProfileUseCase.self, from: resolver)
            let updateUseCase = Self.resolve(UpdateUserProfileUseCase.self, from: resolver)
            return MainActor.assumeIsolated {
                UserInfoViewModel(
                    getUserProfileUseCase: useCase,
                    updateUserProfileUseCase: updateUseCase
                )
            }
        }

        container.register(DailyZonesViewModel.self) { resolver in
            let useCases = DailyZonesUseCases(
                fetchTemplates: Self.resolve(FetchTemplatesUseCase.self, from: resolver),
                fetchOverrides: Self.resolve(FetchTemplateOverridesUseCase.self, from: resolver),
                createTemplate: Self.resolve(CreateTemplateUseCase.self, from: resolver),
                updateTemplateZones: Self.resolve(UpdateTemplateUseCase.self, from: resolver),
                updateTemplateDetails: Self.resolve(UpdateTemplateDetailsUseCase.self, from: resolver),
                deleteTemplate: Self.resolve(DeleteTemplateUseCase.self, from: resolver),
                createOverride: Self.resolve(CreateTemplateOverrideUseCase.self, from: resolver),
                updateOverrideZones: Self.resolve(UpdateBulkTemplateOverrideUseCase.self, from: resolver),
                updateOverrideDetails: Self.resolve(UpdateTemplateOverrideUseCase.self, from: resolver),
                deleteOverride: Self.resolve(DeleteTemplateOverrideUseCase.self, from: resolver),
                getUserProfile: Self.resolve(GetUserProfileUseCase.self, from: resolver),
                manageSchedule: Self.resolve(ManageDailyZoneScheduleUseCase.self, from: resolver),
                resolveWeekdays: Self.resolve(ResolveTemplateWeekdayAvailabilityUseCase.self, from: resolver)
            )
            return MainActor.assumeIsolated {
                DailyZonesViewModel(useCases: useCases)
            }
        }
        .inObjectScope(.container)

        container.register(PresentationFactory.self) { resolver in
            let appCoordinator = Self.resolve(AppCoordinator.self, from: resolver)
            let authenticationState = Self.resolve(AuthenticationState.self, from: resolver)
            let loginViewModel = Self.resolve(LoginViewModel.self, from: resolver)
            let homeViewModel = Self.resolve(HomeViewModel.self, from: resolver)
            let calendarViewModel = Self.resolve(CalendarViewModel.self, from: resolver)
            let scheduleViewModel = Self.resolve(ScheduleTimelineViewModel.self, from: resolver)
            let creationUseCases = Self.resolve(CreationUseCases.self, from: resolver)
            let onboardingViewModel = Self.resolve(OnboardingViewModel.self, from: resolver)
            let profileViewModel = Self.resolve(ProfileViewModel.self, from: resolver)
            let dailyZonesViewModel = Self.resolve(DailyZonesViewModel.self, from: resolver)
            let inboxViewModel = Self.resolve(InboxViewModel.self, from: resolver)

            return MainActor.assumeIsolated {
                PresentationFactory(
                    appCoordinator: appCoordinator,
                    authenticationState: authenticationState,
                    loginViewModel: loginViewModel,
                    homeViewModel: homeViewModel,
                    calendarViewModel: calendarViewModel,
                    scheduleViewModel: scheduleViewModel,
                    creationUseCases: creationUseCases,
                    makeOtpViewModel: { context in
                        Self.resolve(
                            OtpVerificationViewModel.self,
                            argument: context,
                            from: resolver
                        )
                    },
                    onboardingViewModel: onboardingViewModel,
                    profileViewModel: profileViewModel,
                    dailyZonesViewModel: dailyZonesViewModel,
                    makeUserInfoViewModel: {
                        Self.resolve(UserInfoViewModel.self, from: resolver)
                    },
                    inboxViewModel: inboxViewModel
                )
            }
        }
        .inObjectScope(.container)
    }

    private static func makeConflictUseCases(
        resolver: Resolver
    ) -> ScheduleConflictUseCases {
        ScheduleConflictUseCases(
            applyCandidate: resolve(ApplyScheduleCandidateUseCase.self, from: resolver),
            separateOverlap: resolve(
                SeparateOverlappingSessionsUseCase.self,
                from: resolver
            ),
            moveOverlap: resolve(MoveOverlappingSessionUseCase.self, from: resolver),
            shiftGoalChain: resolve(ShiftGoalDependencyChainUseCase.self, from: resolver),
            stackTasks: resolve(StackDependentTasksUseCase.self, from: resolver),
            makeTaskIndependent: resolve(MakeTaskIndependentUseCase.self, from: resolver),
            replanZoneSessions: resolve(ReplanZoneSessionsUseCase.self, from: resolver),
            restoreZone: resolve(RestoreZoneUseCase.self, from: resolver),
            keepFixedOverAllocation: resolve(
                KeepFixedOverAllocationUseCase.self,
                from: resolver
            ),
            trimFixedOverAllocation: resolve(
                TrimFixedOverAllocationUseCase.self,
                from: resolver
            ),
            keepFixedSessionsOutsideZone: resolve(
                KeepFixedSessionsOutsideZoneUseCase.self,
                from: resolver
            ),
            moveFixedSessionsIntoZone: resolve(
                MoveFixedSessionsIntoZoneUseCase.self,
                from: resolver
            ),
            restoreTaskZone: resolve(RestoreTaskZoneUseCase.self, from: resolver)
        )
    }

    private static func resolve<Service>(
        _ serviceType: Service.Type,
        from resolver: Resolver
    ) -> Service {
        guard let service = resolver.resolve(serviceType) else {
            preconditionFailure("Missing Presentation dependency for \(serviceType)")
        }
        return service
    }

    private static func resolve<Service, Argument>(
        _ serviceType: Service.Type,
        argument: Argument,
        from resolver: Resolver
    ) -> Service {
        guard let service = resolver.resolve(serviceType, argument: argument) else {
            preconditionFailure(
                "Missing Presentation dependency for \(serviceType) with argument \(Argument.self)"
            )
        }
        return service
    }
}

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

        container.register(OnboardingViewModel.self) { resolver in
            let useCase = Self.resolve(CompleteOnboardingUseCase.self, from: resolver)
            return MainActor.assumeIsolated {
                OnboardingViewModel(completeOnboardingUseCase: useCase)
            }
        }
        .inObjectScope(.container)

        container.register(PresentationFactory.self) { resolver in
            let appCoordinator = Self.resolve(AppCoordinator.self, from: resolver)
            let authenticationState = Self.resolve(AuthenticationState.self, from: resolver)
            let loginViewModel = Self.resolve(LoginViewModel.self, from: resolver)
            let scheduleViewModel = Self.resolve(ScheduleTimelineViewModel.self, from: resolver)
            let onboardingViewModel = Self.resolve(OnboardingViewModel.self, from: resolver)

            return MainActor.assumeIsolated {
                PresentationFactory(
                    appCoordinator: appCoordinator,
                    authenticationState: authenticationState,
                    loginViewModel: loginViewModel,
                    scheduleViewModel: scheduleViewModel,
                    makeOtpViewModel: { context in
                        Self.resolve(
                            OtpVerificationViewModel.self,
                            argument: context,
                            from: resolver
                        )
                    },
                    onboardingViewModel: onboardingViewModel
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

import Domain
import Presentation
import Swinject

struct PresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(LoginViewModel.self) { resolver in
            let useCase = Self.resolve(RequestOTPUseCase.self, from: resolver)
            return MainActor.assumeIsolated {
                LoginViewModel(requestOTPUseCase: useCase)
            }
        }
        container.register(OtpVerificationViewModel.self) { (resolver, email: String) in
            let useCase = Self.resolve(VerifyOTPUseCase.self, from: resolver)
            return MainActor.assumeIsolated {
                OtpVerificationViewModel(email: email, verifyOTPUseCase: useCase)
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
}

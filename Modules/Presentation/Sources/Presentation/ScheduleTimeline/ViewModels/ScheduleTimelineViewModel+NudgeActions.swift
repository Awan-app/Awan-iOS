extension ScheduleTimelineViewModel {
    func performNudgeAction(_ actionID: String) {
        guard let action = state.activeNudge?.actions.first(where: { $0.id == actionID }) else {
            return
        }
        reduce { $0.activeNudge = nil }
        let selectedDay = state.selectedDay

        switch action.command {
        case .dismiss:
            return
        case let .applyCandidate(candidate):
            runOperation {
                try await self.useCases.conflicts.applyCandidate.execute(
                    candidate,
                    on: selectedDay
                )
            }
        case let .separateOverlap(request):
            runOperation {
                try await self.useCases.conflicts.separateOverlap.execute(
                    request,
                    on: selectedDay
                )
            }
        case let .moveOverlap(request):
            runOperation {
                try await self.useCases.conflicts.moveOverlap.execute(
                    request,
                    on: selectedDay
                )
            }
        case let .shiftGoalChain(request):
            runOperation {
                try await self.useCases.conflicts.shiftGoalChain.execute(
                    request,
                    on: selectedDay
                )
            }
        case let .stackTasks(request):
            runOperation {
                try await self.useCases.conflicts.stackTasks.execute(
                    request,
                    on: selectedDay
                )
            }
        case let .makeTaskIndependent(request):
            runOperation {
                try await self.useCases.conflicts.makeTaskIndependent.execute(
                    request,
                    on: selectedDay
                )
            }
        case let .replanZoneSessions(request):
            runOperation {
                try await self.useCases.conflicts.replanZoneSessions.execute(
                    request,
                    on: selectedDay
                )
            }
        case let .restoreZone(zone):
            runOperation {
                try await self.useCases.conflicts.restoreZone.execute(
                    zone,
                    on: selectedDay
                )
            }
        case let .keepFixedOverAllocation(request):
            runOperation {
                try await self.useCases.conflicts.keepFixedOverAllocation.execute(request)
            }
        case let .trimFixedOverAllocation(request):
            runOperation {
                try await self.useCases.conflicts.trimFixedOverAllocation.execute(request)
            }
        case let .keepFixedSessionsOutsideZone(request):
            runOperation {
                try await self.useCases.conflicts.keepFixedSessionsOutsideZone.execute(request)
            }
        case let .moveFixedSessionsIntoZone(request):
            runOperation {
                try await self.useCases.conflicts.moveFixedSessionsIntoZone.execute(request)
            }
        case let .restoreTaskZone(request):
            runOperation {
                try await self.useCases.conflicts.restoreTaskZone.execute(request)
            }
        }
    }
}

extension ScheduleTimelineViewModel {
    func performNudgeAction(_ actionID: String) {
        guard let action = state.activeNudge?.actions.first(where: { $0.id == actionID }) else {
            return
        }
        reduce { $0.activeNudge = nil }

        switch action.command {
        case .dismiss:
            return
        case let .applyCandidate(candidate):
            runOperation {
                try await self.useCases.conflicts.applyCandidate.execute(candidate)
            }
        case let .separateOverlap(request):
            runOperation {
                try await self.useCases.conflicts.separateOverlap.execute(request)
            }
        case let .moveOverlap(request):
            runOperation {
                try await self.useCases.conflicts.moveOverlap.execute(request)
            }
        case let .shiftGoalChain(request):
            runOperation {
                try await self.useCases.conflicts.shiftGoalChain.execute(request)
            }
        case let .stackTasks(request):
            runOperation {
                try await self.useCases.conflicts.stackTasks.execute(request)
            }
        case let .makeTaskIndependent(request):
            runOperation {
                try await self.useCases.conflicts.makeTaskIndependent.execute(request)
            }
        case let .replanZoneSessions(request):
            runOperation {
                try await self.useCases.conflicts.replanZoneSessions.execute(request)
            }
        case let .restoreZone(zone):
            runOperation {
                try await self.useCases.conflicts.restoreZone.execute(zone)
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

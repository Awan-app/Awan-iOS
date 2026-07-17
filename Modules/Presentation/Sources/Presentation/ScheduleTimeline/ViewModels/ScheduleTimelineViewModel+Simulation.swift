import Domain

extension ScheduleTimelineViewModel {
    func simulate(_ scenario: ScheduleSimulationScenario) {
        let selectedDay = state.selectedDay
        runOperation {
            try await self.useCases.simulation.simulate.execute(
                scenario,
                on: selectedDay,
                in: self.timeZone
            )
        }
    }

    func resetSimulation() {
        reduce { $0.activeNudge = nil }
        runWorkspaceOperation {
            try await self.useCases.simulation.reset.execute()
        }
    }
}

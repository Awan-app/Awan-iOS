public enum ScheduleSimulationScenario: Hashable, Sendable {
    case overlap
    case zoneOverflow
    case missedDependencyChain
    case zoneReconfiguration
}

import Foundation

public enum SchedulingError: Error, Equatable, Sendable {
    case invalidLocalTime(hour: Int, minute: Int)
    case invalidDuration(minutes: Int)
    case invalidTimeRange
    case invalidColorHex(String)
    case invalidConfiguration
    case duplicateTaskID(UUID)
    case missingZone(taskID: UUID, zoneID: UUID)
    case missingDependency(taskID: UUID, dependencyID: UUID)
    case dependencyCycle(taskIDs: Set<UUID>)
}

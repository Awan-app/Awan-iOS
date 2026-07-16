import Foundation

public struct AwanTask: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let goalID: UUID?
    public let zoneID: UUID?
    public let duration: TaskDuration
    public let isSplittable: Bool
    public let dependencyIDs: Set<UUID>

    public init(
        id: UUID,
        goalID: UUID? = nil,
        zoneID: UUID? = nil,
        duration: TaskDuration,
        isSplittable: Bool,
        dependencyIDs: Set<UUID> = []
    ) {
        self.id = id
        self.goalID = goalID
        self.zoneID = zoneID
        self.duration = duration
        self.isSplittable = isSplittable
        self.dependencyIDs = dependencyIDs
    }
}

import Foundation

public struct AwanTask: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let goalID: UUID?
    public let zoneID: UUID?
    public let duration: TaskDuration
    public let isSplittable: Bool
    public let dependencyIDs: Set<UUID>

    public init(
        id: UUID,
        title: String = "Untitled Task",
        goalID: UUID? = nil,
        zoneID: UUID? = nil,
        duration: TaskDuration,
        isSplittable: Bool,
        dependencyIDs: Set<UUID> = []
    ) {
        self.id = id
        self.title = title
        self.goalID = goalID
        self.zoneID = zoneID
        self.duration = duration
        self.isSplittable = isSplittable
        self.dependencyIDs = dependencyIDs
    }
}

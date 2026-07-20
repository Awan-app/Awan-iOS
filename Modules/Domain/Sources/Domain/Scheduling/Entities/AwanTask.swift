import Foundation

public enum TaskStatus: String, Hashable, Sendable {
    case pending
    case inProgress
    case completed
    case cancelled
}

public struct AwanTask: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let status: TaskStatus
    public let goalID: UUID?
    public let zoneID: UUID?
    public let duration: TaskDuration
    public let isSplittable: Bool
    public let mandatory: Bool
    public let estimatedPoints: Int
    public let dependencyIDs: Set<UUID>

    public init(
        id: UUID,
        title: String = "Untitled Task",
        description: String? = nil,
        status: TaskStatus = .pending,
        goalID: UUID? = nil,
        zoneID: UUID? = nil,
        duration: TaskDuration,
        isSplittable: Bool,
        mandatory: Bool = true,
        estimatedPoints: Int = 0,
        dependencyIDs: Set<UUID> = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.goalID = goalID
        self.zoneID = zoneID
        self.duration = duration
        self.isSplittable = isSplittable
        self.mandatory = mandatory
        self.estimatedPoints = estimatedPoints
        self.dependencyIDs = dependencyIDs
    }
}

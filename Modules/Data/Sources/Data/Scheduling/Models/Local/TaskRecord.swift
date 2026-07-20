import Foundation

public struct TaskRecord: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let statusRaw: String
    public let goalID: UUID?
    public let zoneID: UUID?
    public let estimatedDurationMinutes: Int
    public let allowTaskSplitting: Bool
    public let mandatory: Bool
    public let estimatedPoints: Int
    public let dependencyIDs: [UUID]
    public let order: Int

    public init(
        id: UUID,
        title: String,
        description: String?,
        statusRaw: String,
        goalID: UUID?,
        zoneID: UUID?,
        estimatedDurationMinutes: Int,
        allowTaskSplitting: Bool,
        mandatory: Bool,
        estimatedPoints: Int,
        dependencyIDs: [UUID],
        order: Int = 0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.statusRaw = statusRaw
        self.goalID = goalID
        self.zoneID = zoneID
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.allowTaskSplitting = allowTaskSplitting
        self.mandatory = mandatory
        self.estimatedPoints = estimatedPoints
        self.dependencyIDs = dependencyIDs
        self.order = order
    }
}

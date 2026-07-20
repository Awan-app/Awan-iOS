import Domain
import Foundation

public struct GoalRecord: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let status: GoalStatus
    public let deadline: Date
    public let createdAt: Date

    public init(
        id: UUID,
        title: String,
        description: String?,
        status: GoalStatus,
        deadline: Date,
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.deadline = deadline
        self.createdAt = createdAt
    }
}

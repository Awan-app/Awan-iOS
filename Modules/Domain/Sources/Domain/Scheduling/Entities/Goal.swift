import Foundation

public enum GoalStatus: String, Hashable, Sendable {
    case active
    case completed
    case cancelled
}

public struct Goal: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let description: String?
    public let status: GoalStatus
    public let deadline: Date
    public let createdAt: Date

    public init(
        id: UUID,
        name: String,
        description: String? = nil,
        status: GoalStatus = .active,
        deadline: Date,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.status = status
        self.deadline = deadline
        self.createdAt = createdAt
    }
}

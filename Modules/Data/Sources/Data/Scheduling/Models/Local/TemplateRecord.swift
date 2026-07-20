import Foundation

public struct TemplateRecord: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let createdAt: Date
    public let dayOfWeek: Int
    public let userID: UUID

    public init(
        id: UUID,
        name: String,
        createdAt: Date,
        dayOfWeek: Int,
        userID: UUID
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.dayOfWeek = dayOfWeek
        self.userID = userID
    }
}

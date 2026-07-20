import Foundation

public struct TemplateOverride: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let createdAt: Date
    public let dateOfDay: Date
    public let userID: UUID

    public init(
        id: UUID,
        name: String,
        createdAt: Date = Date(),
        dateOfDay: Date,
        userID: UUID
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.dateOfDay = dateOfDay
        self.userID = userID
    }
}

import Domain
import Foundation

public struct TemplateData: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let createdAt: Date
    public let weekDays: Set<Int>
    public let zones: [Zone]

    public init(
        id: UUID,
        name: String,
        createdAt: Date = Date(),
        weekDays: Set<Int>,
        zones: [Zone]
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.weekDays = weekDays
        self.zones = zones
    }
}

public struct TemplateOverrideData: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let createdAt: Date
    public let dateOfDay: Date
    public let zones: [Zone]

    public init(
        id: UUID,
        name: String,
        createdAt: Date = Date(),
        dateOfDay: Date,
        zones: [Zone]
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.dateOfDay = dateOfDay
        self.zones = zones
    }
}

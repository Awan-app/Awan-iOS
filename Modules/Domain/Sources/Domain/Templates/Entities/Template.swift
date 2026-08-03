import Foundation

public struct Template: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let name: String
    public let daysOfWeek: Set<TemplateWeekday>
    public let zones: [Zone]

    public init(id: UUID, name: String, daysOfWeek: Set<TemplateWeekday>, zones: [Zone]) {
        self.id = id
        self.name = name
        self.daysOfWeek = daysOfWeek
        self.zones = zones
    }
}

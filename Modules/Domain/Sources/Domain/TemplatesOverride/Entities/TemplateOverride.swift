import Foundation

public struct TemplateOverride: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let name: String?
    public let dateOfDay: TemplateOverrideDate
    public let zones: [Zone]

    public init(
        id: UUID,
        name: String?,
        dateOfDay: TemplateOverrideDate,
        zones: [Zone]
    ) {
        self.id = id
        self.name = name
        self.dateOfDay = dateOfDay
        self.zones = zones
    }
}

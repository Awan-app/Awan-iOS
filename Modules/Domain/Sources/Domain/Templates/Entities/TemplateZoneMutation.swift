import Foundation

public struct TemplateZoneMutation: Hashable, Sendable {
    public let id: UUID?
    public let name: String
    public let color: ZoneColor
    public let startTime: LocalTime
    public let endTime: LocalTime
    public let category: TaskCategory?

    public init(
        id: UUID?,
        name: String,
        color: ZoneColor,
        startTime: LocalTime,
        endTime: LocalTime,
        category: TaskCategory?
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.startTime = startTime
        self.endTime = endTime
        self.category = category
    }

    public init(existing zone: Zone) {
        self.init(
            id: zone.id,
            name: zone.name,
            color: zone.color,
            startTime: zone.startTime,
            endTime: zone.endTime,
            category: zone.category
        )
    }
}

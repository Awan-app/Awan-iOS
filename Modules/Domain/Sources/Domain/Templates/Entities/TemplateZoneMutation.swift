import Foundation

public struct TemplateZoneMutation: Hashable, Sendable {
    public let id: UUID?
    public let name: String
    public let color: ZoneColor
    public let startTime: LocalTime
    public let endTime: LocalTime

    public init(
        id: UUID?,
        name: String,
        color: ZoneColor,
        startTime: LocalTime,
        endTime: LocalTime
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.startTime = startTime
        self.endTime = endTime
    }

    public init(existing zone: Zone) {
        self.init(
            id: zone.id,
            name: zone.name,
            color: zone.color,
            startTime: zone.startTime,
            endTime: zone.endTime
        )
    }
}

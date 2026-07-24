import Foundation

public struct ZoneWithoutId: Hashable, Sendable {
    public let name: String
    public let startTime: LocalTime
    public let endTime: LocalTime
    public let color: ZoneColor

    public init(
        name: String,
        color: ZoneColor,
        startTime: LocalTime,
        endTime: LocalTime
    ) {
        self.name = name
        self.color = color
        self.startTime = startTime
        self.endTime = endTime
    }
}

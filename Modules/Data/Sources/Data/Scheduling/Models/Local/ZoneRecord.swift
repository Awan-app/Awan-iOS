import Foundation

public struct ZoneRecord: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let colorHex: String
    public let startHour: Int
    public let startMinute: Int
    public let endHour: Int
    public let endMinute: Int
    public let templateID: UUID?
    public let templateOverrideID: UUID?

    public init(
        id: UUID,
        name: String,
        colorHex: String,
        startHour: Int,
        startMinute: Int,
        endHour: Int,
        endMinute: Int,
        templateID: UUID? = nil,
        templateOverrideID: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.templateID = templateID
        self.templateOverrideID = templateOverrideID
    }
}

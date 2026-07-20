import Foundation

public struct FixedZoneDataSource: LocalZoneDataSource {
    public init() {}

    public static var defaultRecords: [ZoneRecord] {
        [
            ZoneRecord(
                id: UUID(uuid: (0xA1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01)),
                name: "Morning", colorHex: "#F4B942",
                startHour: 7, startMinute: 0, endHour: 9, endMinute: 0
            ),
            ZoneRecord(
                id: UUID(uuid: (0xA1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02)),
                name: "Work", colorHex: "#4A90E2",
                startHour: 9, startMinute: 0, endHour: 17, endMinute: 0
            ),
            ZoneRecord(
                id: UUID(uuid: (0xA1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03)),
                name: "Study", colorHex: "#8E5BD9",
                startHour: 18, startMinute: 0, endHour: 21, endMinute: 0
            ),
            ZoneRecord(
                id: UUID(uuid: (0xA1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04)),
                name: "Personal", colorHex: "#EF6C8F",
                startHour: 21, startMinute: 0, endHour: 0, endMinute: 0
            ),
        ]
    }

    public func fetchZones() async throws -> [ZoneRecord] {
        Self.defaultRecords
    }

    public func updateZone(_ zone: ZoneRecord) async throws {}

    public func resetZones() async throws {
    }
}

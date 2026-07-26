import Foundation

public struct BulkUpdateZonesRequestDTO: Encodable, Sendable {
    public let zones: [ZonePayload]

    public init(zones: [ZonePayload]) {
        self.zones = zones
    }

    public struct ZonePayload: Encodable, Sendable {
        public let name: String
        public let startTime: String
        public let endTime: String
        public let color: String

        public init(name: String, startTime: String, endTime: String, color: String) {
            self.name = name
            self.startTime = startTime
            self.endTime = endTime
            self.color = color
        }
    }
}

import Foundation

public struct BulkUpdateOverrideZonesRequestDTO: Encodable, Sendable {
    public let zones: [ZonePayload]

    public init(zones: [ZonePayload]) {
        self.zones = zones
    }

    public struct ZonePayload: Encodable, Sendable {
        public let id: String?
        public let name: String
        public let startTime: String
        public let endTime: String
        public let color: String
        public let categoryId: UUID

        public init(
            id: String? = nil,
            name: String,
            startTime: String,
            endTime: String,
            color: String,
            categoryId: UUID
        ) {
            self.id = id
            self.name = name
            self.startTime = startTime
            self.endTime = endTime
            self.color = color
            self.categoryId = categoryId
        }
    }
}

public struct DailyWheelConfigResponseDTO: Decodable, Sendable {
    public let segments: [DailyWheelSegmentDTO]
    public let claimedToday: Bool
    public let lastClaim: DailyWheelClaimDTO?
}

public struct DailyWheelSegmentDTO: Decodable, Sendable {
    public let segmentId: String
    public let coins: Int
    public let payoutType: String
}

public struct DailyWheelClaimDTO: Decodable, Sendable {
    public let segmentId: String
    public let coinsAwarded: Int
    public let itemId: String?
    public let itemName: String?
    public let claimDate: String
    public let claimedAt: String
}

public struct DailyWheelSpinResponseDTO: Decodable, Sendable {
    public let segmentId: String
    public let payoutType: String
    public let coinsAwarded: Int
    public let newBalance: Int
    public let item: DailyWheelRewardItemDTO?
}

public struct DailyWheelRewardItemDTO: Decodable, Sendable {
    public let id: String
    public let name: String
    public let description: String?
    public let image: String?
    public let info: String?
    public let price: Int?
    public let version: String?
    public let type: String?
}

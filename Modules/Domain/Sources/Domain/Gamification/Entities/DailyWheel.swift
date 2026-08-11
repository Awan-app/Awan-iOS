import Foundation

public enum GamificationPayoutType: String, Equatable, Sendable {
    case coins
    case item
}

public struct DailyWheelSegment: Identifiable, Equatable, Sendable {
    public let id: String
    public let coins: Int
    public let payoutType: GamificationPayoutType

    public init(id: String, coins: Int, payoutType: GamificationPayoutType) {
        self.id = id
        self.coins = coins
        self.payoutType = payoutType
    }
}

public struct DailyWheelClaim: Equatable, Sendable {
    public let segmentID: String
    public let coinsAwarded: Int
    public let itemID: String?
    public let itemName: String?
    public let claimDate: String
    public let claimedAt: String

    public init(
        segmentID: String,
        coinsAwarded: Int,
        itemID: String?,
        itemName: String?,
        claimDate: String,
        claimedAt: String
    ) {
        self.segmentID = segmentID
        self.coinsAwarded = coinsAwarded
        self.itemID = itemID
        self.itemName = itemName
        self.claimDate = claimDate
        self.claimedAt = claimedAt
    }
}

public struct DailyWheelConfiguration: Equatable, Sendable {
    public let segments: [DailyWheelSegment]
    public let claimedToday: Bool
    public let lastClaim: DailyWheelClaim?

    public init(
        segments: [DailyWheelSegment],
        claimedToday: Bool,
        lastClaim: DailyWheelClaim?
    ) {
        self.segments = segments
        self.claimedToday = claimedToday
        self.lastClaim = lastClaim
    }
}

public struct GamificationRewardItem: Equatable, Sendable {
    public let id: String
    public let name: String
    public let description: String?
    public let imageURL: URL?
    public let info: String?
    public let price: Int?
    public let version: String?
    public let type: String?

    public init(
        id: String,
        name: String,
        description: String?,
        imageURL: URL?,
        info: String?,
        price: Int?,
        version: String?,
        type: String?
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.info = info
        self.price = price
        self.version = version
        self.type = type
    }
}

public struct DailyWheelSpinResult: Equatable, Sendable {
    public let segmentID: String
    public let payoutType: GamificationPayoutType
    public let coinsAwarded: Int
    public let newBalance: Int
    public let item: GamificationRewardItem?

    public init(
        segmentID: String,
        payoutType: GamificationPayoutType,
        coinsAwarded: Int,
        newBalance: Int,
        item: GamificationRewardItem?
    ) {
        self.segmentID = segmentID
        self.payoutType = payoutType
        self.coinsAwarded = coinsAwarded
        self.newBalance = newBalance
        self.item = item
    }
}

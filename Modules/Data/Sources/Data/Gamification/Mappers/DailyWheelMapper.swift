import Domain
import Foundation

enum DailyWheelMapper {
    static func configuration(
        _ dto: DailyWheelConfigResponseDTO
    ) throws -> DailyWheelConfiguration {
        guard !dto.segments.isEmpty else {
            throw GamificationError.invalidWheelConfiguration
        }

        let segments = try dto.segments.map { segment in
            DailyWheelSegment(
                id: segment.segmentId,
                coins: segment.coins,
                payoutType: try payoutType(segment.payoutType)
            )
        }

        guard Set(segments.map(\.id)).count == segments.count else {
            throw GamificationError.invalidWheelConfiguration
        }

        return DailyWheelConfiguration(
            segments: segments,
            claimedToday: dto.claimedToday,
            lastClaim: dto.lastClaim.map {
                DailyWheelClaim(
                    segmentID: $0.segmentId,
                    coinsAwarded: $0.coinsAwarded,
                    itemID: $0.itemId,
                    itemName: $0.itemName,
                    claimDate: $0.claimDate,
                    claimedAt: $0.claimedAt
                )
            }
        )
    }

    static func spinResult(
        _ dto: DailyWheelSpinResponseDTO
    ) throws -> DailyWheelSpinResult {
        let type = try payoutType(dto.payoutType)
        if type == .item, dto.item == nil {
            throw GamificationError.invalidWheelConfiguration
        }

        return DailyWheelSpinResult(
            segmentID: dto.segmentId,
            payoutType: type,
            coinsAwarded: dto.coinsAwarded,
            newBalance: dto.newBalance,
            item: dto.item.map {
                GamificationRewardItem(
                    id: $0.id,
                    name: $0.name,
                    description: $0.description,
                    imageURL: $0.image.flatMap(URL.init(string:)),
                    info: $0.info,
                    price: $0.price,
                    version: $0.version,
                    type: $0.type
                )
            }
        )
    }

    private static func payoutType(
        _ value: String
    ) throws -> GamificationPayoutType {
        switch value {
        case "COINS": .coins
        case "ITEM": .item
        default: throw GamificationError.invalidWheelConfiguration
        }
    }
}

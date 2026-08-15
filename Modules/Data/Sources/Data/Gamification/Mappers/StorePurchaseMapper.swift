//
//  StorePurchaseMapper.swift
//  Data
//

import Domain
import Foundation

public enum StorePurchaseMapper {
    public static func map(_ dto: StorePurchaseResponseDTO) -> StorePurchase {
        let item = StoreItemMapper.map(dto.item)
        let boughtAtDate = parseISO8601Date(dto.boughtAt)
        return StorePurchase(
            id: dto.id,
            item: item,
            boughtAt: boughtAtDate
        )
    }

    private static func parseISO8601Date(_ string: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string) ?? Date()
    }
}

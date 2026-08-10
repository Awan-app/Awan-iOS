//
//  EquippedItemMapper.swift
//  Data
//

import Domain
import Foundation

public enum EquippedItemMapper {
    public static func map(_ dto: EquippedItemResponseDTO) -> EquippedItem {
        let item = StoreItemMapper.map(dto.item)
        let equippedAtDate = parseISO8601Date(dto.equippedAt)
        return EquippedItem(
            type: dto.type,
            item: item,
            equippedAt: equippedAtDate
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

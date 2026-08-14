//
//  InventoryItemMapper.swift
//  Data
//

import Domain
import Foundation

public enum InventoryItemMapper {
    public static func map(_ dto: InventoryItemResponseDTO) -> InventoryItem {
        let item = StoreItemMapper.map(dto.item)
        let boughtAtDate = parseISO8601Date(dto.boughtAt)
        return InventoryItem(
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

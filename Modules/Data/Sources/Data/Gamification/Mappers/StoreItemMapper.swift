//
//  StoreItemMapper.swift
//  Data
//

import Domain

public enum StoreItemMapper {
    public static func map(_ dto: StoreItemResponseDTO) -> StoreItem {
        StoreItem(
            id: dto.id,
            name: dto.name,
            description: dto.description,
            image: dto.image,
            info: dto.info,
            price: dto.price,
            version: dto.version,
            type: StoreItemType(apiValue: dto.type)
        )
    }

    public static func map(_ dtos: [StoreItemResponseDTO]) -> [StoreItem] {
        dtos.map { map($0) }
    }
}

import Domain
import Foundation
import SwiftData

@Model
final class EquippedItemModel {
    @Attribute(.unique) var typeRaw: String
    var equippedAt: Date
    var itemID: String
    var itemName: String
    var itemDescription: String
    var itemImage: String
    var itemInfo: String?
    var itemPrice: Int
    var itemVersion: String
    var itemTypeRaw: String

    init(item: EquippedItem) {
        typeRaw = item.type.rawValue
        equippedAt = item.equippedAt
        itemID = item.item.id
        itemName = item.item.name
        itemDescription = item.item.description
        itemImage = item.item.image
        itemInfo = item.item.info
        itemPrice = item.item.price
        itemVersion = item.item.version
        itemTypeRaw = item.item.type.rawValue
    }

    func update(from item: EquippedItem) {
        typeRaw = item.type.rawValue
        equippedAt = item.equippedAt
        itemID = item.item.id
        itemName = item.item.name
        itemDescription = item.item.description
        itemImage = item.item.image
        itemInfo = item.item.info
        itemPrice = item.item.price
        itemVersion = item.item.version
        itemTypeRaw = item.item.type.rawValue
    }

    func toDomain() -> EquippedItem {
        EquippedItem(
            type: StoreItemType(apiValue: typeRaw),
            item: StoreItem(
                id: itemID,
                name: itemName,
                description: itemDescription,
                image: itemImage,
                info: itemInfo,
                price: itemPrice,
                version: itemVersion,
                type: StoreItemType(apiValue: itemTypeRaw)
            ),
            equippedAt: equippedAt
        )
    }
}

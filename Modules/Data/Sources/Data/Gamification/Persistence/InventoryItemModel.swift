import Domain
import Foundation
import SwiftData

@Model
final class InventoryItemModel {
    @Attribute(.unique) var id: String
    var boughtAt: Date
    var itemID: String
    var itemName: String
    var itemDescription: String
    var itemImage: String
    var itemInfo: String?
    var itemPrice: Int
    var itemVersion: String
    var itemTypeRaw: String

    init(item: InventoryItem) {
        id = item.id
        boughtAt = item.boughtAt
        itemID = item.item.id
        itemName = item.item.name
        itemDescription = item.item.description
        itemImage = item.item.image
        itemInfo = item.item.info
        itemPrice = item.item.price
        itemVersion = item.item.version
        itemTypeRaw = item.item.type.rawValue
    }

    func update(from item: InventoryItem) {
        boughtAt = item.boughtAt
        itemID = item.item.id
        itemName = item.item.name
        itemDescription = item.item.description
        itemImage = item.item.image
        itemInfo = item.item.info
        itemPrice = item.item.price
        itemVersion = item.item.version
        itemTypeRaw = item.item.type.rawValue
    }

    func toDomain() -> InventoryItem {
        InventoryItem(
            id: id,
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
            boughtAt: boughtAt
        )
    }
}

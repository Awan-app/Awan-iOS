import Domain
import Foundation
import SwiftData

@Model
final class StoreItemModel {
    @Attribute(.unique) var id: String
    var name: String
    var itemDescription: String
    var image: String
    var info: String?
    var price: Int
    var version: String
    var typeRaw: String

    init(item: StoreItem) {
        id = item.id
        name = item.name
        itemDescription = item.description
        image = item.image
        info = item.info
        price = item.price
        version = item.version
        typeRaw = item.type.rawValue
    }

    func update(from item: StoreItem) {
        name = item.name
        itemDescription = item.description
        image = item.image
        info = item.info
        price = item.price
        version = item.version
        typeRaw = item.type.rawValue
    }

    func toDomain() -> StoreItem {
        StoreItem(
            id: id,
            name: name,
            description: itemDescription,
            image: image,
            info: info,
            price: price,
            version: version,
            type: StoreItemType(apiValue: typeRaw)
        )
    }
}

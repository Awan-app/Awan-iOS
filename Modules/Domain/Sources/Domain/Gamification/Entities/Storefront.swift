import Foundation

public struct Storefront: Equatable, Sendable {
    public enum ItemState: Equatable, Sendable {
        case available
        case owned
        case equipped
    }

    public struct Item: Identifiable, Equatable, Sendable {
        public var id: String { storeItem.id }
        public let storeItem: StoreItem
        public fileprivate(set) var state: ItemState

        public init(storeItem: StoreItem, state: ItemState) {
            self.storeItem = storeItem
            self.state = state
        }
    }

    public private(set) var items: [Item]

    public static let empty = Storefront(items: [])

    public init(items: [Item]) {
        self.items = items
    }

    public init(
        catalog: [StoreItem],
        inventory: [InventoryItem],
        equippedItems: [EquippedItem]
    ) {
        let ownedIDs = Set(inventory.map(\.item.id))
        let equippedIDs = Set(equippedItems.map(\.item.id))

        self.items = catalog.map { item in
            let state: ItemState
            if equippedIDs.contains(item.id) {
                state = .equipped
            } else if ownedIDs.contains(item.id) {
                state = .owned
            } else {
                state = .available
            }
            return Item(storeItem: item, state: state)
        }
    }

    public mutating func recordPurchase(_ purchase: StorePurchase) {
        guard let index = items.firstIndex(where: { $0.id == purchase.item.id }) else {
            return
        }
        items[index].state = .owned
    }

    public mutating func recordEquipment(_ equippedItem: EquippedItem) {
        for index in items.indices {
            if items[index].id == equippedItem.item.id {
                items[index].state = .equipped
            } else if items[index].storeItem.type == equippedItem.type,
                      items[index].state == .equipped {
                items[index].state = .owned
            }
        }
    }

    public mutating func recordUnequip(ofType type: StoreItemType) {
        for index in items.indices where items[index].storeItem.type == type
            && items[index].state == .equipped {
            items[index].state = .owned
        }
    }
}

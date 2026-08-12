public struct StoreLoadout: Equatable, Sendable {
    public private(set) var items: [EquippedItem]

    public init(items: [EquippedItem] = []) {
        self.items = items
    }

    public mutating func equip(_ item: EquippedItem) {
        items.removeAll { $0.type == item.type }
        items.append(item)
    }

    public mutating func unequip(_ type: StoreItemType) {
        items.removeAll { $0.type == type }
    }
}

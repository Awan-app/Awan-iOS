//
//  MarketplacePresentationModels.swift
//  Presentation
//

import Foundation

// MARK: - Category

public enum MarketplaceItemCategory: String, CaseIterable, Identifiable, Sendable {
    case all
    case frames
    case skins
    case themes
    case appIcons

    public var id: String { rawValue }
}

// MARK: - Status

public enum MarketplaceItemStatus: Sendable, Equatable {
    case price(Int)
    case owned
    case equipped
    case locked
}

// MARK: - Item

public struct MarketplaceItem: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let description: String
    public let category: MarketplaceItemCategory
    public var status: MarketplaceItemStatus
    public let symbolName: String
    public let isNew: Bool

    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        category: MarketplaceItemCategory,
        status: MarketplaceItemStatus,
        symbolName: String,
        isNew: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.status = status
        self.symbolName = symbolName
        self.isNew = isNew
    }

    public static func == (lhs: MarketplaceItem, rhs: MarketplaceItem) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Filter

public struct MarketplaceFilter: Sendable, Equatable {
    public var selectedCategories: Set<MarketplaceItemCategory>
    public var minPrice: Double
    public var maxPrice: Double

    public static let maxPtsCap: Double = 1500

    public static let `default` = MarketplaceFilter(
        selectedCategories: Set(MarketplaceItemCategory.allCases.filter { $0 != .all }),
        minPrice: 0,
        maxPrice: maxPtsCap
    )

    public var isDefault: Bool {
        minPrice == 0 && maxPrice == Self.maxPtsCap
            && selectedCategories == Set(MarketplaceItemCategory.allCases.filter { $0 != .all })
    }
}

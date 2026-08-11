//
//  MarketplacePresentationModels.swift
//  Presentation
//

import Domain
import Foundation

// MARK: - Category

public enum MarketplaceItemCategory: String, CaseIterable, Identifiable, Sendable {
    case all
    case frames
    case skins
    case themes
    case appIcons

    public var id: String { rawValue }

    public var apiType: String? {
        switch self {
        case .all:
            return nil
        case .frames:
            return "FRAME"
        case .skins:
            return "SKIN"
        case .themes:
            return "THEME"
        case .appIcons:
            return "ICON"
        }
    }
}

// MARK: - Status

public enum MarketplaceItemStatus: Sendable, Equatable,Hashable {
    case price(Int)
    case owned
    case equipped
    case locked
}

// MARK: - Item

public struct MarketplaceItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let category: MarketplaceItemCategory
    public var status: MarketplaceItemStatus
    public let symbolName: String
    public let imageURL: String?
    public let isNew: Bool

    public init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        category: MarketplaceItemCategory,
        status: MarketplaceItemStatus,
        symbolName: String,
        imageURL: String? = nil,
        isNew: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.status = status
        self.symbolName = symbolName
        self.imageURL = imageURL
        self.isNew = isNew
    }

    public init(storeItem: StoreItem) {
        self.id = storeItem.id
        self.name = storeItem.name
        self.description = storeItem.description
        self.imageURL = storeItem.image
        self.status = .price(storeItem.price)
        self.isNew = false

        switch storeItem.type.uppercased() {
        case "FRAME":
            self.category = .frames
            self.symbolName = "square.on.circle"
        case "SKIN":
            self.category = .skins
            self.symbolName = "paintpalette.fill"
        case "THEME":
            self.category = .themes
            self.symbolName = "globe"
        case "ICON":
            self.category = .appIcons
            self.symbolName = "square.grid.2x2.fill"
        default:
            self.category = .skins
            self.symbolName = "sparkles"
        }
    }

    public static func == (lhs: MarketplaceItem, rhs: MarketplaceItem) -> Bool {
        lhs.id == rhs.id && lhs.status == rhs.status
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(status)
    }
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

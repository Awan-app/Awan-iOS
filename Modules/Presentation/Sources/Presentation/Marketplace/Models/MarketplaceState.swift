//
//  MarketplaceState.swift
//  Presentation
//

import Foundation
import Domain

public enum PurchaseFeedback: Sendable, Equatable {
    public enum SuccessKind: Sendable, Equatable {
        case purchase
        case equipment
        case unequipment
    }

    case success(message: String, kind: SuccessKind)
    case failure(message: String)
    case unequipFailure(message: String)
}

public struct MarketplaceState: Sendable {
    public var storefront: Storefront = .empty
    public var userPoints: Int = 0

    public var isLoading: Bool = false
    public var errorMessage: String? = nil

    public var purchasingItemID: String? = nil
    public var equippingItemID: String? = nil
    public var unequippingItemType: StoreItemType? = nil
    public var purchaseFeedback: PurchaseFeedback? = nil

    public var searchQuery: String = ""
    public var selectedCategory: MarketplaceItemCategory = .all

    public var isFilterSheetPresented: Bool = false
    public var appliedFilter: MarketplaceFilter = .default

    public var selectedItemID: String? = nil

    public init() {}

    public var allItems: [MarketplaceItem] {
        storefront.items.map(MarketplaceItem.init(storefrontItem:))
    }

    public var selectedItem: MarketplaceItem? {
        guard let selectedItemID else { return nil }
        return allItems.first { $0.id == selectedItemID }
    }

    public var filteredItems: [MarketplaceItem] {
        allItems.filter { item in
            let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            let searchMatch = trimmedQuery.isEmpty
                || item.name.localizedCaseInsensitiveContains(trimmedQuery)
                || item.description.localizedCaseInsensitiveContains(trimmedQuery)

            let selectedCategoryMatch = selectedCategory == .all || item.category == selectedCategory
            let filterCategoryMatch = item.category == .all
                || appliedFilter.selectedCategories.contains(item.category)
            let ownershipMatch = !appliedFilter.showsOnlyNotOwned || {
                if case .price = item.status { return true }
                return false
            }()

            let priceMatch: Bool
            switch item.status {
            case let .price(pts):
                let ptsDouble = Double(pts)
                if appliedFilter.maxPrice >= MarketplaceFilter.maxPtsCap {
                    priceMatch = ptsDouble >= appliedFilter.minPrice
                } else {
                    priceMatch = ptsDouble >= appliedFilter.minPrice && ptsDouble <= appliedFilter.maxPrice
                }
            default:
                priceMatch = true
            }

            return searchMatch
                && selectedCategoryMatch
                && filterCategoryMatch
                && ownershipMatch
                && priceMatch
        }
    }

    public var hasActiveFilters: Bool {
        let allFilterableCount = MarketplaceItemCategory.allCases.filter { $0 != .all }.count
        let categoriesFiltered = appliedFilter.selectedCategories.count != allFilterableCount
        let priceFiltered = !appliedFilter.isDefault
        let searchFiltered = !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return categoriesFiltered || priceFiltered || searchFiltered
    }
}

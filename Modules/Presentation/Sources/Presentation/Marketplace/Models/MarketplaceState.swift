//
//  MarketplaceState.swift
//  Presentation
//

import Foundation

public enum PurchaseFeedback: Sendable, Equatable {
    case success(message: String)
    case failure(message: String)
}

public struct MarketplaceState: Sendable {
    public var allItems: [MarketplaceItem] = []
    public var userPoints: Int = 1_240

    public var isLoading: Bool = false
    public var errorMessage: String? = nil

    public var purchasingItemID: String? = nil
    public var purchaseErrorMessage: String? = nil
    public var purchaseSuccessMessage: String? = nil
    public var purchaseFeedback: PurchaseFeedback? = nil

    public var searchQuery: String = ""
    public var selectedCategory: MarketplaceItemCategory = .all

    public var isFilterSheetPresented: Bool = false
    public var pendingFilter: MarketplaceFilter = .default
    public var appliedFilter: MarketplaceFilter = .default

    public var selectedItem: MarketplaceItem? = nil

    public init() {}

    public var filteredItems: [MarketplaceItem] {
        allItems.filter { item in
            let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            let searchMatch = trimmedQuery.isEmpty
                || item.name.localizedCaseInsensitiveContains(trimmedQuery)
                || item.description.localizedCaseInsensitiveContains(trimmedQuery)

            let typeMatch = appliedFilter.selectedCategories.contains(item.category)

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

            return searchMatch && typeMatch && priceMatch
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

//
//  MarketplaceAction.swift
//  Presentation
//

import Foundation

public enum MarketplaceAction: Sendable {
    case appeared
    case selectCategory(MarketplaceItemCategory)
    case searchQueryChanged(String)
    case toggleFilterSheet
    case applyFilter(MarketplaceFilter)
    case resetFilters
    case selectItem(MarketplaceItem)
    case dismissDetail
    case buyItem(MarketplaceItem)
    case equipItem(MarketplaceItem)
    case dismissPurchaseError
    case dismissPurchaseFeedback
    case retry
}

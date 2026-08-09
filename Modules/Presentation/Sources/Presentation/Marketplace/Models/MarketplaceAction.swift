//
//  MarketplaceAction.swift
//  Presentation
//

import Foundation

public enum MarketplaceAction: Sendable {
    case appeared
    case searchQueryChanged(String)
    case toggleFilterSheet
    case applyFilter(MarketplaceFilter)
    case resetFilters
    case selectItem(MarketplaceItem)
    case dismissDetail
}

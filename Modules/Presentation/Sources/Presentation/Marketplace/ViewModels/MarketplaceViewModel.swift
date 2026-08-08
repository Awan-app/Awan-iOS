import Foundation
import Observation

@Observable
@MainActor
public final class MarketplaceViewModel {
    public var state: MarketplaceState

    public init() {
        self.state = MarketplaceState()
    }

    public func send(_ action: MarketplaceAction) {
        switch action {
        case .appeared:
            loadMockItems()

        case let .searchQueryChanged(query):
            state.searchQuery = query

        case .toggleFilterSheet:
            state.isFilterSheetPresented.toggle()

        case let .applyFilter(filter):
            state.appliedFilter = filter
            state.isFilterSheetPresented = false

        case .resetFilters:
            state.appliedFilter = .default
            state.pendingFilter = .default
            state.isFilterSheetPresented = false

        case let .selectItem(item):
            state.selectedItem = item

        case .dismissDetail:
            state.selectedItem = nil
        }
    }

    private func loadMockItems() {
        guard state.allItems.isEmpty else { return }
        state.allItems = Self.mockItems
    }

    private static let mockItems: [MarketplaceItem] = [
        MarketplaceItem(
            name: "Cloud Halo Frame",
            description: "A fluffy cloud halo that surrounds your avatar with a dreamy aura.",
            category: .frames,
            status: .price(250),
            symbolName: "cloud.circle.fill"
        ),
        MarketplaceItem(
            name: "Neon Ring Frame",
            description: "A vibrant neon ring that makes your avatar glow in the dark.",
            category: .frames,
            status: .equipped,
            symbolName: "record.circle.fill"
        ),
        MarketplaceItem(
            name: "Golden Frame",
            description: "A premium golden frame that shows off your achievements.",
            category: .frames,
            status: .owned,
            symbolName: "circle.circle.fill"
        ),
        MarketplaceItem(
            name: "Wizard Cloud",
            description: "A magical look for your loyal cloud companion.",
            category: .skins,
            status: .price(200),
            symbolName: "cloud.fill",
            isNew: true
        ),
        MarketplaceItem(
            name: "Sleepy Cloud",
            description: "A cozy bedtime look for when you've earned your rest.",
            category: .skins,
            status: .locked,
            symbolName: "moon.zzz.fill"
        ),
        MarketplaceItem(
            name: "Cool Cloud",
            description: "Look cool with sunglasses on your cloud companion.",
            category: .skins,
            status: .price(350),
            symbolName: "sun.max.fill"
        ),
        MarketplaceItem(
            name: "Ocean Theme",
            description: "A deep-sea themed interface with calming blue tones.",
            category: .themes,
            status: .equipped,
            symbolName: "water.waves"
        ),
        MarketplaceItem(
            name: "Midnight Theme",
            description: "A dark, starry night theme perfect for late-night sessions.",
            category: .themes,
            status: .price(300),
            symbolName: "moon.stars.fill"
        ),
        MarketplaceItem(
            name: "Sunset Theme",
            description: "Warm orange and pink hues inspired by a beautiful sunset.",
            category: .themes,
            status: .price(500),
            symbolName: "sunset.fill"
        ),
        MarketplaceItem(
            name: "Blue Spark Icon",
            description: "A sparkling blue icon that stands out on your home screen.",
            category: .appIcons,
            status: .price(150),
            symbolName: "bolt.circle.fill"
        ),
        MarketplaceItem(
            name: "Moon Icon",
            description: "A serene moon icon for a calming home screen aesthetic.",
            category: .appIcons,
            status: .locked,
            symbolName: "moon.fill"
        ),
        MarketplaceItem(
            name: "Star Gem Icon",
            description: "A gem-studded star icon that shows off your premium status.",
            category: .appIcons,
            status: .price(250),
            symbolName: "star.circle.fill",
            isNew: true
        ),
    ]
}

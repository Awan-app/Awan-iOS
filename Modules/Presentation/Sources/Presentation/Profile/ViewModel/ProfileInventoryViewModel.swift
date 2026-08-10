//
//  ProfileInventoryViewModel.swift
//  Presentation
//

import Common
import Domain
import Foundation
import Observation

public enum ProfileInventoryAction: Sendable {
    case appeared
    case refresh
    case retry
    case selectCategory(MarketplaceItemCategory)
    case selectItem(MarketplaceItem)
    case dismissDetail
    case equipItem(MarketplaceItem)
    case unequipItem(MarketplaceItem)
    case dismissFeedback
}

@Observable
@MainActor
public final class ProfileInventoryViewModel {
    public private(set) var catalogItems: [StoreItem] = []
    public private(set) var inventoryItems: [InventoryItem] = []
    public private(set) var equippedItems: [EquippedItem] = []
    public var selectedCategory: MarketplaceItemCategory = .all

    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String? = nil
    public private(set) var equippingItemID: String? = nil
    public private(set) var unequippingItemType: String? = nil

    public var selectedItem: MarketplaceItem? = nil
    public private(set) var feedbackMessage: String? = nil

    @ObservationIgnored private let fetchStoreInventoryUseCase: any FetchStoreInventoryUseCase
    @ObservationIgnored private let fetchEquippedItemsUseCase: any FetchEquippedItemsUseCase
    @ObservationIgnored private let fetchStoreItemsUseCase: any FetchStoreItemsUseCase
    @ObservationIgnored private let equipStoreItemUseCase: any EquipStoreItemUseCase
    @ObservationIgnored private let unequipStoreItemUseCase: any UnequipStoreItemUseCase

    public init(
        fetchStoreInventoryUseCase: any FetchStoreInventoryUseCase,
        fetchEquippedItemsUseCase: any FetchEquippedItemsUseCase,
        fetchStoreItemsUseCase: any FetchStoreItemsUseCase,
        equipStoreItemUseCase: any EquipStoreItemUseCase,
        unequipStoreItemUseCase: any UnequipStoreItemUseCase
    ) {
        self.fetchStoreInventoryUseCase = fetchStoreInventoryUseCase
        self.fetchEquippedItemsUseCase = fetchEquippedItemsUseCase
        self.fetchStoreItemsUseCase = fetchStoreItemsUseCase
        self.equipStoreItemUseCase = equipStoreItemUseCase
        self.unequipStoreItemUseCase = unequipStoreItemUseCase
    }

    public func send(_ action: ProfileInventoryAction) {
        switch action {
        case .appeared, .refresh, .retry:
            loadInventoryAndEquipped()

        case let .selectCategory(category):
            selectedCategory = category

        case let .selectItem(item):
            selectedItem = item

        case .dismissDetail:
            selectedItem = nil

        case let .equipItem(item):
            equipItem(item)

        case let .unequipItem(item):
            unequipItem(item)

        case .dismissFeedback:
            feedbackMessage = nil
        }
    }

    // MARK: - Derived State

    public var displayedEquippedItems: [EquippedItem] {
        if selectedCategory == .all {
            return equippedItems
        }
        guard let apiType = selectedCategory.apiType else { return equippedItems }
        return equippedItems.filter { $0.type.uppercased() == apiType.uppercased() }
    }

    public var displayedOwnedItems: [MarketplaceItem] {
        let equippedIDs = Set(equippedItems.map { $0.item.id })

        return inventoryItems.compactMap { inventoryItem -> MarketplaceItem? in
            var item = MarketplaceItem(storeItem: inventoryItem.item)
            item.status = equippedIDs.contains(inventoryItem.item.id) ? .equipped : .owned

            if selectedCategory != .all && item.category != selectedCategory {
                return nil
            }

            return item
        }
    }

    public var displayedLockedItems: [MarketplaceItem] {
        let ownedIDs = Set(inventoryItems.map { $0.item.id })

        return catalogItems.compactMap { storeItem -> MarketplaceItem? in
            guard !ownedIDs.contains(storeItem.id) else { return nil }

            var item = MarketplaceItem(storeItem: storeItem)
            item.status = .locked

            if selectedCategory != .all && item.category != selectedCategory {
                return nil
            }

            return item
        }
    }

    // MARK: - Async Operations

    public func loadInventoryAndEquipped() {
        isLoading = true
        errorMessage = nil

        let fetchInventory = fetchStoreInventoryUseCase
        let fetchEquipped = fetchEquippedItemsUseCase
        let fetchCatalog = fetchStoreItemsUseCase

        Task { [weak self] in
            do {
                async let inventoryTask = fetchInventory.execute()
                async let equippedTask = fetchEquipped.execute()
                async let catalogTask = fetchCatalog.execute(type: "") 

                let (inventory, equipped, catalog) = try await (inventoryTask, equippedTask, catalogTask)

                guard let self else { return }
                self.inventoryItems = inventory
                self.equippedItems = equipped
                self.catalogItems = catalog
                self.isLoading = false
            } catch {
                guard let self else { return }
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    private func equipItem(_ item: MarketplaceItem) {
        guard equippingItemID == nil, unequippingItemType == nil else { return }
        guard item.status == .owned else { return }

        equippingItemID = item.id
        feedbackMessage = nil

        let useCase = equipStoreItemUseCase
        let itemID = item.id

        Task { [weak self] in
            do {
                let newlyEquipped = try await useCase.execute(itemID: itemID)

                guard let self else { return }
                self.equippingItemID = nil

                // Update equippedItems array: replace existing of same type, or append
                var updatedEquipped = self.equippedItems.filter { $0.type.uppercased() != newlyEquipped.type.uppercased() }
                updatedEquipped.append(newlyEquipped)
                self.equippedItems = updatedEquipped

                if var selected = self.selectedItem, selected.id == itemID {
                    selected.status = .equipped
                    self.selectedItem = selected
                }

                self.feedbackMessage = L10n.Marketplace.currentlyEquipped
            } catch {
                guard let self else { return }
                self.equippingItemID = nil

                let msg: String
                if let gamificationError = error as? GamificationError {
                    switch gamificationError {
                    case .itemNotOwned:
                        msg = L10n.Marketplace.itemNotOwned
                    default:
                        msg = error.localizedDescription
                    }
                } else {
                    msg = error.localizedDescription
                }
                self.errorMessage = msg
            }
        }
    }

    private func unequipItem(_ item: MarketplaceItem) {
        guard equippingItemID == nil, unequippingItemType == nil else { return }
        guard let apiType = item.category.apiType else { return }

        unequippingItemType = apiType
        feedbackMessage = nil

        let useCase = unequipStoreItemUseCase

        Task { [weak self] in
            do {
                try await useCase.execute(type: apiType)

                guard let self else { return }
                self.unequippingItemType = nil

                // Remove item of that type from equippedItems
                self.equippedItems.removeAll { $0.type.uppercased() == apiType.uppercased() }

                if var selected = self.selectedItem, selected.id == item.id {
                    selected.status = .owned
                    self.selectedItem = selected
                }
            } catch {
                guard let self else { return }
                self.unequippingItemType = nil
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

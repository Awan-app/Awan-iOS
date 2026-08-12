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
    private var equippedLoadout = StoreLoadout()
    public var selectedCategory: MarketplaceItemCategory = .all

    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String? = nil
    public private(set) var equippingItemID: String? = nil
    public private(set) var unequippingItemType: StoreItemType? = nil

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

    public var equippedItems: [EquippedItem] {
        equippedLoadout.items
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
                async let catalogTask = fetchCatalog.execute()

                let (inventory, equipped, catalog) = try await (inventoryTask, equippedTask, catalogTask)

                guard let self else { return }
                self.inventoryItems = inventory
                self.equippedLoadout = StoreLoadout(items: equipped)
                self.catalogItems = catalog
                self.isLoading = false
            } catch {
                guard let self else { return }
                self.errorMessage = GamificationErrorMessageMapper.message(for: error)
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

                self.equippedLoadout.equip(newlyEquipped)

                if var selected = self.selectedItem, selected.id == itemID {
                    selected.status = .equipped
                    self.selectedItem = selected
                }

                self.feedbackMessage = L10n.Marketplace.currentlyEquipped
            } catch {
                guard let self else { return }
                self.equippingItemID = nil

                self.errorMessage = GamificationErrorMessageMapper.message(for: error)
            }
        }
    }

    private func unequipItem(_ item: MarketplaceItem) {
        guard equippingItemID == nil, unequippingItemType == nil else { return }
        guard let itemType = item.category.storeItemType else { return }

        unequippingItemType = itemType
        feedbackMessage = nil

        let useCase = unequipStoreItemUseCase

        Task { [weak self] in
            do {
                try await useCase.execute(type: itemType)

                guard let self else { return }
                self.unequippingItemType = nil

                self.equippedLoadout.unequip(itemType)

                if var selected = self.selectedItem, selected.id == item.id {
                    selected.status = .owned
                    self.selectedItem = selected
                }
            } catch {
                guard let self else { return }
                self.unequippingItemType = nil
                self.errorMessage = GamificationErrorMessageMapper.message(for: error)
            }
        }
    }
}

import Domain
import Common
import Foundation
import Observation

@Observable
@MainActor
public final class MarketplaceViewModel {
    public var state: MarketplaceState

    @ObservationIgnored private let fetchStoreItemsUseCase: any FetchStoreItemsUseCase
    @ObservationIgnored private let buyStoreItemUseCase: any BuyStoreItemUseCase
    @ObservationIgnored private let equipStoreItemUseCase: any EquipStoreItemUseCase
    @ObservationIgnored private let fetchEquippedItemsUseCase: (any FetchEquippedItemsUseCase)?
    @ObservationIgnored private let fetchUserPointsUseCase: any FetchUserPointsUseCase

    public init(
        fetchStoreItemsUseCase: any FetchStoreItemsUseCase,
        buyStoreItemUseCase: any BuyStoreItemUseCase,
        equipStoreItemUseCase: any EquipStoreItemUseCase,
        fetchEquippedItemsUseCase: (any FetchEquippedItemsUseCase)? = nil,
        fetchUserPointsUseCase: any FetchUserPointsUseCase
    ) {
        self.fetchStoreItemsUseCase = fetchStoreItemsUseCase
        self.buyStoreItemUseCase = buyStoreItemUseCase
        self.equipStoreItemUseCase = equipStoreItemUseCase
        self.fetchEquippedItemsUseCase = fetchEquippedItemsUseCase
        self.fetchUserPointsUseCase = fetchUserPointsUseCase
        self.state = MarketplaceState()
    }

    public func send(_ action: MarketplaceAction) {
        switch action {
        case .appeared, .retry:
            loadUserPoints()
            loadStoreItems()

        case let .selectCategory(category):
            state.selectedCategory = category
            loadStoreItems()

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

        case let .buyItem(item):
            buyStoreItem(item)

        case let .equipItem(item):
            equipStoreItem(item)

        case .dismissPurchaseError:
            state.purchaseErrorMessage = nil

        case .dismissPurchaseFeedback:
            state.purchaseFeedback = nil
        }
    }

    private func loadUserPoints() {
        state.isLoadingPoints = true
        let useCase = fetchUserPointsUseCase

        Task { [weak self] in
            do {
                let points = try await useCase.execute()
                guard let self else { return }
                self.state.userPoints = points
                self.state.isLoadingPoints = false
            } catch {
                guard let self else { return }
                self.state.isLoadingPoints = false
            }
        }
    }

    private func loadStoreItems() {
        let category = state.selectedCategory
        state.isLoading = true
        state.errorMessage = nil

        let fetchItemsUseCase = fetchStoreItemsUseCase
        let fetchEquippedUseCase = fetchEquippedItemsUseCase

        Task { [weak self] in
            do {
                let domainItems: [StoreItem]
                if let apiType = category.apiType {
                    domainItems = try await fetchItemsUseCase.execute(type: apiType)
                } else {
                    let validTypes = ["FRAME", "SKIN", "THEME", "ICON"]
                    domainItems = try await withThrowingTaskGroup(of: [StoreItem].self) { group in
                        for type in validTypes {
                            group.addTask {
                                try await fetchItemsUseCase.execute(type: type)
                            }
                        }
                        var aggregated: [StoreItem] = []
                        for try await items in group {
                            aggregated.append(contentsOf: items)
                        }
                        return aggregated
                    }
                }

                var equippedIDs: Set<String> = []
                if let fetchEquippedUseCase {
                    if let equipped = try? await fetchEquippedUseCase.execute() {
                        equippedIDs = Set(equipped.map { $0.item.id })
                    }
                }

                guard let self else { return }
                self.state.allItems = domainItems.map { domainItem in
                    var item = MarketplaceItem(storeItem: domainItem)
                    if equippedIDs.contains(domainItem.id) {
                        item.status = .equipped
                    }
                    return item
                }
                self.state.isLoading = false
            } catch {
                guard let self else { return }
                self.state.errorMessage = error.localizedDescription
                self.state.allItems = []
                self.state.isLoading = false
            }
        }
    }

    private func buyStoreItem(_ item: MarketplaceItem) {
        guard state.purchasingItemID == nil else { return }

        state.purchasingItemID = item.id
        state.purchaseFeedback = nil
        state.purchaseErrorMessage = nil

        let useCase = buyStoreItemUseCase
        let itemID = item.id

        Task { [weak self] in
            do {
                _ = try await useCase.execute(itemID: itemID)

                guard let self else { return }
                self.state.purchasingItemID = nil

                if let index = self.state.allItems.firstIndex(where: { $0.id == itemID }) {
                    self.state.allItems[index].status = .owned
                }

                if var selected = self.state.selectedItem, selected.id == itemID {
                    selected.status = .owned
                    self.state.selectedItem = selected
                }

                self.loadUserPoints()
                self.state.purchaseSuccessMessage = L10n.Marketplace.itsYours
                self.state.purchaseFeedback = .success(message: L10n.Marketplace.itsYours)
                self.scheduleFeedbackDismissal()
            } catch {
                guard let self else { return }
                self.state.purchasingItemID = nil

                let message: String
                if let gamificationError = error as? GamificationError, gamificationError == .insufficientPoints {
                    message = L10n.Marketplace.needMorePts
                } else {
                    message = error.localizedDescription
                }
                self.state.purchaseErrorMessage = message
                self.state.purchaseFeedback = .failure(message: message)
                self.scheduleFeedbackDismissal()
            }
        }
    }

    private func equipStoreItem(_ item: MarketplaceItem) {
        guard state.equippingItemID == nil else { return }
        guard item.status == .owned || item.status == .equipped else { return }

        state.equippingItemID = item.id
        state.purchaseFeedback = nil
        state.purchaseErrorMessage = nil

        let useCase = equipStoreItemUseCase
        let itemID = item.id
        let category = item.category

        Task { [weak self] in
            do {
                _ = try await useCase.execute(itemID: itemID)

                guard let self else { return }
                self.state.equippingItemID = nil

                // Update store items state: replace equipped item of same category with owned status
                for i in 0..<self.state.allItems.count {
                    if self.state.allItems[i].id == itemID {
                        self.state.allItems[i].status = .equipped
                    } else if self.state.allItems[i].category == category && self.state.allItems[i].status == .equipped {
                        self.state.allItems[i].status = .owned
                    }
                }

                if var selected = self.state.selectedItem {
                    if selected.id == itemID {
                        selected.status = .equipped
                        self.state.selectedItem = selected
                    } else if selected.category == category && selected.status == .equipped {
                        selected.status = .owned
                        self.state.selectedItem = selected
                    }
                }

                self.state.purchaseSuccessMessage = L10n.Marketplace.currentlyEquipped
                self.state.purchaseFeedback = .success(message: L10n.Marketplace.currentlyEquipped)
                self.scheduleFeedbackDismissal()
            } catch {
                guard let self else { return }
                self.state.equippingItemID = nil

                let message: String
                if let gamificationError = error as? GamificationError {
                    switch gamificationError {
                    case .itemNotOwned:
                        message = L10n.Marketplace.itemNotOwned
                    default:
                        message = GamificationErrorMessageMapper.message(for: gamificationError)
                    }
                } else {
                    message = error.localizedDescription
                }

                self.state.purchaseErrorMessage = message
                self.state.purchaseFeedback = .failure(message: message)
                self.scheduleFeedbackDismissal()
            }
        }
    }

    private func scheduleFeedbackDismissal() {
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard let self else { return }
            self.state.purchaseFeedback = nil
        }
    }
}

import Domain
import Common
import Foundation
import Observation

@Observable
@MainActor
public final class MarketplaceViewModel {
    public var state: MarketplaceState

    @ObservationIgnored private let fetchStorefrontUseCase: any FetchStorefrontUseCase
    @ObservationIgnored private let buyStoreItemUseCase: any BuyStoreItemUseCase
    @ObservationIgnored private let equipStoreItemUseCase: any EquipStoreItemUseCase
    @ObservationIgnored private let unequipStoreItemUseCase: (any UnequipStoreItemUseCase)?
    @ObservationIgnored private let fetchUserPointsUseCase: any FetchUserPointsUseCase

    public init(
        fetchStorefrontUseCase: any FetchStorefrontUseCase,
        buyStoreItemUseCase: any BuyStoreItemUseCase,
        equipStoreItemUseCase: any EquipStoreItemUseCase,
        unequipStoreItemUseCase: (any UnequipStoreItemUseCase)? = nil,
        fetchUserPointsUseCase: any FetchUserPointsUseCase
    ) {
        self.fetchStorefrontUseCase = fetchStorefrontUseCase
        self.buyStoreItemUseCase = buyStoreItemUseCase
        self.equipStoreItemUseCase = equipStoreItemUseCase
        self.unequipStoreItemUseCase = unequipStoreItemUseCase
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

        case let .searchQueryChanged(query):
            state.searchQuery = query

        case .toggleFilterSheet:
            state.isFilterSheetPresented.toggle()

        case let .applyFilter(filter):
            state.appliedFilter = filter
            state.isFilterSheetPresented = false

        case .resetFilters:
            state.appliedFilter = .default
            state.isFilterSheetPresented = false

        case let .selectItem(item):
            state.selectedItemID = item.id

        case .dismissDetail:
            state.selectedItemID = nil

        case let .buyItem(item):
            buyStoreItem(item)

        case let .equipItem(item):
            equipStoreItem(item)

        case let .unequipItem(item):
            unequipStoreItem(item)

        }
    }

    private func loadUserPoints() {
        let useCase = fetchUserPointsUseCase

        Task { [weak self] in
            do {
                let points = try await useCase.execute()
                guard let self else { return }
                self.state.userPoints = points
            } catch {
                return
            }
        }
    }

    private func loadStoreItems() {
        state.isLoading = true
        state.errorMessage = nil

        let useCase = fetchStorefrontUseCase

        Task { [weak self] in
            do {
                let storefront = try await useCase.execute()

                guard let self else { return }
                self.state.storefront = storefront
                self.state.isLoading = false
            } catch {
                guard let self else { return }
                self.state.errorMessage = error.localizedDescription
                self.state.storefront = .empty
                self.state.isLoading = false
            }
        }
    }

    private func buyStoreItem(_ item: MarketplaceItem) {
        guard state.purchasingItemID == nil else { return }

        state.purchasingItemID = item.id
        state.purchaseFeedback = nil

        let useCase = buyStoreItemUseCase
        let itemID = item.id

        Task { [weak self] in
            do {
                let purchase = try await useCase.execute(itemID: itemID)

                guard let self else { return }
                self.state.purchasingItemID = nil

                self.state.storefront.recordPurchase(purchase)

                self.loadUserPoints()
                self.state.purchaseFeedback = .success(
                    message: L10n.Marketplace.itsYours,
                    kind: .purchase
                )
                self.scheduleFeedbackDismissal()
            } catch {
                guard let self else { return }
                self.state.purchasingItemID = nil

                let message = GamificationErrorMessageMapper.message(for: error)
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

        let useCase = equipStoreItemUseCase
        let itemID = item.id
        Task { [weak self] in
            do {
                let equippedItem = try await useCase.execute(itemID: itemID)

                guard let self else { return }
                self.state.equippingItemID = nil

                self.state.storefront.recordEquipment(equippedItem)

                self.state.purchaseFeedback = .success(
                    message: L10n.Marketplace.equippedHint,
                    kind: .equipment
                )
                self.scheduleFeedbackDismissal()
            } catch {
                guard let self else { return }
                self.state.equippingItemID = nil

                let message = GamificationErrorMessageMapper.message(for: error)
                self.state.purchaseFeedback = .failure(message: message)
                self.scheduleFeedbackDismissal()
            }
        }
    }

    private func unequipStoreItem(_ item: MarketplaceItem) {
        guard state.equippingItemID == nil, state.unequippingItemType == nil else { return }
        guard item.status == .equipped,
              let itemType = item.category.storeItemType,
              let useCase = unequipStoreItemUseCase else { return }

        state.unequippingItemType = itemType
        state.purchaseFeedback = nil

        Task { [weak self] in
            do {
                try await useCase.execute(type: itemType)

                guard let self else { return }
                self.state.unequippingItemType = nil
                self.state.storefront.recordUnequip(ofType: itemType)
            } catch {
                guard let self else { return }
                self.state.unequippingItemType = nil
                self.state.purchaseFeedback = .failure(
                    message: GamificationErrorMessageMapper.message(for: error)
                )
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

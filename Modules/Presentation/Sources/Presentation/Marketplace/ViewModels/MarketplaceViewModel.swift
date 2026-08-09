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

    public init(
        fetchStoreItemsUseCase: any FetchStoreItemsUseCase,
        buyStoreItemUseCase: any BuyStoreItemUseCase
    ) {
        self.fetchStoreItemsUseCase = fetchStoreItemsUseCase
        self.buyStoreItemUseCase = buyStoreItemUseCase
        self.state = MarketplaceState()
    }

    public func send(_ action: MarketplaceAction) {
        switch action {
        case .appeared, .retry:
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

        case .dismissPurchaseError:
            state.purchaseErrorMessage = nil

        case .dismissPurchaseFeedback:
            state.purchaseFeedback = nil
        }
    }

    private func loadStoreItems() {
        let category = state.selectedCategory
        state.isLoading = true
        state.errorMessage = nil

        let useCase = fetchStoreItemsUseCase

        Task { [weak self] in
            do {
                let domainItems: [StoreItem]
                if let apiType = category.apiType {
                    domainItems = try await useCase.execute(type: apiType)
                } else {
                    let validTypes = ["FRAME", "SKIN", "THEME", "ICON"]
                    domainItems = try await withThrowingTaskGroup(of: [StoreItem].self) { group in
                        for type in validTypes {
                            group.addTask {
                                try await useCase.execute(type: type)
                            }
                        }
                        var aggregated: [StoreItem] = []
                        for try await items in group {
                            aggregated.append(contentsOf: items)
                        }
                        return aggregated
                    }
                }

                guard let self else { return }
                self.state.allItems = domainItems.map { MarketplaceItem(storeItem: $0) }
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
                let purchase = try await useCase.execute(itemID: itemID)

                guard let self else { return }
                self.state.purchasingItemID = nil

                if let index = self.state.allItems.firstIndex(where: { $0.id == itemID }) {
                    self.state.allItems[index].status = .owned
                }

                if var selected = self.state.selectedItem, selected.id == itemID {
                    selected.status = .owned
                    self.state.selectedItem = selected
                }

                self.state.userPoints = max(0, self.state.userPoints - purchase.item.price)
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

    private func scheduleFeedbackDismissal() {
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard let self else { return }
            self.state.purchaseFeedback = nil
        }
    }
}

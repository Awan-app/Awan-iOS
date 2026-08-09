import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class MarketplaceViewModel {
    public var state: MarketplaceState

    @ObservationIgnored private let fetchStoreItemsUseCase: any FetchStoreItemsUseCase

    public init(fetchStoreItemsUseCase: any FetchStoreItemsUseCase) {
        self.fetchStoreItemsUseCase = fetchStoreItemsUseCase
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
}

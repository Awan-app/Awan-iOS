import Domain
import Common
import SwiftUI

public struct MarketplaceView: View {
    @State private var viewModel: MarketplaceViewModel

    private let gridColumns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    public init(viewModel: MarketplaceViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        let state = viewModel.state

        ZStack(alignment: .top) {
            AppColors.screenBackground.ignoresSafeArea()

            AppCloudsHorizon(height: 190)
                .offset(y: 8)

            content(state)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            viewModel.send(.appeared)
        }
        .sheet(isPresented: Binding(
            get: { state.isFilterSheetPresented },
            set: { isPresented in
                if !isPresented && viewModel.state.isFilterSheetPresented {
                    viewModel.send(.toggleFilterSheet)
                }
            }
        )) {
            MarketplaceFilterSheet(
                initialFilter: state.appliedFilter,
                onApply: { newFilter in
                    viewModel.send(.applyFilter(newFilter))
                },
                onReset: {
                    viewModel.send(.resetFilters)
                }
            )
            .presentationDetents([.height(510), .large])
            .presentationDragIndicator(.hidden)
            .presentationBackground(AppColors.surface)
        }
        .sheet(item: Binding(
            get: { state.selectedItem },
            set: { if $0 == nil { viewModel.send(.dismissDetail) } }
        )) { item in
            MarketplaceItemDetailSheet(
                item: item,
                userPoints: state.userPoints,
                isPurchasing: state.purchasingItemID == item.id,
                isEquipping: state.equippingItemID == item.id,
                isUnequipping: state.unequippingItemType == item.category.storeItemType,
                purchaseFeedback: state.purchaseFeedback,
                onBuy: { viewModel.send(.buyItem(item)) },
                onEquip: { viewModel.send(.equipItem(item)) },
                onUnequip: { viewModel.send(.unequipItem(item)) },
                onDismiss: { viewModel.send(.dismissDetail) }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(AppColors.surface)
        }
    }

    private func content(_ state: MarketplaceState) -> some View {
        VStack(spacing: 16) {
            headerRow
                .padding(.bottom, -6)

            MarketplacePointsCard(points: state.userPoints)

            searchFilterBar(state)

            MarketplaceCategoryChips(
                selectedCategory: Binding(
                    get: { state.selectedCategory },
                    set: { viewModel.send(.selectCategory($0)) }
                )
            )

            ScrollView {
                LazyVStack(spacing: 12) {
                    if state.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else if state.errorMessage != nil {
                        OfflineView {
                            viewModel.send(.retry)
                        }
                    } else if state.filteredItems.isEmpty {
                        MarketplaceEmptyView()
                            .padding(.top, 20)
                    } else {
                        LazyVGrid(columns: gridColumns, spacing: 12) {
                            ForEach(state.filteredItems) { item in
                                MarketplaceItemCard(item: item) {
                                    viewModel.send(.selectItem(item))
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 120)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var headerRow: some View {
        HStack(alignment: .center) {
            Text(L10n.Marketplace.title)
                .font(AppFonts.bigTitle)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()
        }
        .frame(minHeight: 64)
    }

    private func searchFilterBar(_ state: MarketplaceState) -> some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.7))

                TextField(L10n.Marketplace.searchPlaceholder, text: Binding(
                    get: { state.searchQuery },
                    set: { viewModel.send(.searchQueryChanged($0)) }
                ))
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textPrimary)
                .autocorrectionDisabled()

                if !state.searchQuery.isEmpty {
                    Button {
                        viewModel.send(.searchQueryChanged(""))
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppColors.outline.opacity(0.12), lineWidth: 1.5)
            )

            let sheetOpen = state.isFilterSheetPresented
            Button {
                viewModel.send(.toggleFilterSheet)
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(sheetOpen ? AppColors.onAccent : AppColors.accentBlue)
                        .frame(width: 46, height: 46)

                    if state.hasActiveFilters && !sheetOpen {
                        Circle()
                            .fill(AppColors.accentBlue)
                            .frame(width: 8, height: 8)
                            .overlay {
                                Circle()
                                    .stroke(AppColors.surface, lineWidth: 2)
                            }
                            .offset(x: -3, y: 3)
                    }
                }
            }
            .buttonStyle(
                AppDepthButtonStyle(
                    shape: .roundedRectangle(cornerRadius: 16),
                    surfaceColor: sheetOpen ? AppColors.accentBlue : AppColors.surface,
                    borderColor: AppColors.accentBlue.opacity(0.35),
                    depthColor: sheetOpen
                        ? AppColors.accentBlueDepth
                        : AppColors.accentBlueDepth.opacity(0.25),
                    borderWidth: 1.5,
                    depthOffset: 4,
                    pressedOffset: 2
                )
            )
            .accessibilityLabel(sheetOpen ? L10n.Marketplace.hideFilters : L10n.Marketplace.showFilters)
            .accessibilityValue(state.hasActiveFilters ? L10n.Marketplace.filtersApplied : L10n.Marketplace.noFiltersApplied)
        }
    }
}

//#Preview("Marketplace Light") {
//    MarketplaceView(viewModel: MarketplaceViewModel(fetchStoreItemsUseCase: MockFetchStoreItemsUseCase()))
//        .preferredColorScheme(.light)
//}
//
//#Preview("Marketplace Dark") {
//    MarketplaceView(viewModel: MarketplaceViewModel(fetchStoreItemsUseCase: MockFetchStoreItemsUseCase()))
//        .preferredColorScheme(.dark)
//}

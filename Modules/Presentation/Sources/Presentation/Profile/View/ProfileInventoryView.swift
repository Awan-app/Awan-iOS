//
//  ProfileInventoryView.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

public struct ProfileInventoryView: View {
    @State private var viewModel: ProfileInventoryViewModel

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    public init(viewModel: ProfileInventoryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ZStack {
            AppColors.screenBackground.ignoresSafeArea()

            content
        }
        .navigationTitle(L10n.Profile.inventory)
        .foregroundColor(AppColors.brandDarkBlue)
        .font( AppFonts.titleBlack)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AwanMascotView(state: .normal)
                    .frame(width: 42, height: 32)
            }
        }
        .task {
            viewModel.send(.appeared)
        }
        .sheet(item: Binding(
            get: { viewModel.selectedItem },
            set: { if $0 == nil { viewModel.send(.dismissDetail) } }
        )) { item in
            MarketplaceItemDetailSheet(
                item: item,
                userPoints: 0,
                isPurchasing: false,
                isEquipping: viewModel.equippingItemID == item.id,
                purchaseFeedback: nil,
                onBuy: {},
                onEquip: {
                    if item.status == .equipped {
                        viewModel.send(.unequipItem(item))
                    } else if item.status == .owned {
                        viewModel.send(.equipItem(item))
                    }
                },
                onDismiss: { viewModel.send(.dismissDetail) }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(AppColors.surface)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .tint(AppColors.accentBlue)
                .frame(maxWidth: .infinity, minHeight: 360)
        } else if let errorMessage = viewModel.errorMessage {
            VStack(spacing: 16) {
                NetworkErrorView(message: errorMessage)
                Button {
                    viewModel.send(.retry)
                } label: {
                    Text(L10n.Marketplace.retry)
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.accentBlue)
                }
            }
            .padding(24)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    categoryFilterBar

                    ProfileEquippedItemsSection(
                        equippedItems: viewModel.displayedEquippedItems,
                        unequippingItemType: viewModel.unequippingItemType,
                        onUnequip: { item in
                            viewModel.send(.unequipItem(item))
                        }
                    )

                    ownedItemsSection

                    ProfileLockedItemsSection(
                        lockedItems: viewModel.displayedLockedItems,
                        onItemTap: { item in
                            viewModel.send(.selectItem(item))
                        }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 60)
            }
            .refreshable {
                viewModel.send(.refresh)
            }
        }
    }

    private var categoryFilterBar: some View {
        MarketplaceCategoryChips(
            selectedCategory: Binding(
                get: { viewModel.selectedCategory },
                set: { viewModel.send(.selectCategory($0)) }
            )
        )
    }

    @ViewBuilder
    private var ownedItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(
                title: "\(L10n.Profile.ownedItems) (\(viewModel.displayedOwnedItems.count))",
                accentColor: AppColors.accentBlue
            )

            if viewModel.displayedOwnedItems.isEmpty {
                emptyView
            } else {
                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ForEach(viewModel.displayedOwnedItems) { item in
                        InventoryItemCard(item: item, overrideState: .owned) {
                            viewModel.send(.selectItem(item))
                        }
                    }
                }
            }
        }
    }

    private var emptyView: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 20),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.outline.opacity(0.12),
            depthColor: AppColors.outline.opacity(0.16),
            borderWidth: 1.5,
            depthOffset: 4,
            contentInsets: EdgeInsets(top: 24, leading: 20, bottom: 24, trailing: 20)
        ) {
            VStack(spacing: 12) {
                Image(systemName: "shippingbox")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(AppColors.accentPurple)

                Text(L10n.Profile.emptyInventoryTitle)
                    .font(AppFonts.title3Bold)
                    .foregroundStyle(AppColors.textPrimary)

                Text(L10n.Profile.emptyInventorySubtitle)
                    .font(AppFonts.subheadlineSemibold)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 10)
    }
}

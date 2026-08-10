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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
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
                    } else {
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
                VStack(alignment: .leading, spacing: 18) {
                    categoryFilterBar

                    ownershipFilterBar

                    ProfileEquippedItemsSection(
                        equippedItems: viewModel.displayedEquippedItems,
                        isUnequipping: viewModel.unequippingItemType != nil,
                        onUnequip: { item in
                            viewModel.send(.unequipItem(item))
                        }
                    )

                    SectionHeaderLabel(
                        title: L10n.Profile.ownedItems,
                        accentColor: AppColors.accentBlue
                    )

                    if viewModel.displayedItems.isEmpty {
                        emptyView
                    } else {
                        LazyVGrid(columns: gridColumns, spacing: 12) {
                            ForEach(viewModel.displayedItems) { item in
                                MarketplaceItemCard(item: item) {
                                    viewModel.send(.selectItem(item))
                                }
                            }
                        }
                    }
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

    private var ownershipFilterBar: some View {
        HStack(spacing: 10) {
            filterChip(
                title: L10n.Marketplace.filterAll,
                isSelected: !viewModel.showOwnedOnly,
                onTap: {
                    if viewModel.showOwnedOnly {
                        viewModel.send(.toggleOwnedFilter)
                    }
                }
            )

            filterChip(
                title: L10n.Profile.filterOwned,
                isSelected: viewModel.showOwnedOnly,
                onTap: {
                    if !viewModel.showOwnedOnly {
                        viewModel.send(.toggleOwnedFilter)
                    }
                }
            )

            Spacer()
        }
    }

    private func filterChip(title: String, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            Text(title)
                .font(AppFonts.subheadlineBold)
                .foregroundStyle(isSelected ? AppColors.onAccent : AppColors.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? AppColors.accentPurple : AppColors.surface)
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? AppColors.accentPurple : AppColors.outline.opacity(0.18),
                            lineWidth: 1.5
                        )
                )
        }
        .buttonStyle(.plain)
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

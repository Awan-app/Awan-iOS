//
//  ProfileEquippedItemsSection.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct ProfileEquippedItemsSection: View {
    let equippedItems: [EquippedItem]
    var unequippingItemType: StoreItemType? = nil
    let onSelect: (MarketplaceItem) -> Void

    private struct SlotDefinition {
        let type: StoreItemType
        let displayName: String
        let emptyMessage: String
        let placeholderImageName: String
    }

    private let fixedSlots: [SlotDefinition] = [
        SlotDefinition(type: .frame, displayName: L10n.Marketplace.filterFrames, emptyMessage: L10n.Profile.noActiveFrame, placeholderImageName: "EmptyStoreFrame"),
        SlotDefinition(type: .skin, displayName: L10n.Marketplace.filterSkins, emptyMessage: L10n.Profile.noActiveSkin, placeholderImageName: "EmptyStoreSkin"),
        SlotDefinition(type: .theme, displayName: L10n.Marketplace.filterThemes, emptyMessage: L10n.Profile.noActiveTheme, placeholderImageName: "EmptyStoreTheme"),
        SlotDefinition(type: .icon, displayName: L10n.Marketplace.filterAppIcons, emptyMessage: L10n.Profile.noActiveAppIcon, placeholderImageName: "EmptyStoreAppIcon")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(
                title: L10n.Profile.equippedItems,
                accentColor: AppColors.accentGreen
            )

            HStack(alignment: .top, spacing: 8) {
                ForEach(fixedSlots, id: \.displayName) { slot in
                    let matchingEquipped = equippedItems.first { item in
                        slot.type == item.type
                    }

                    slotCardView(for: slot, equipped: matchingEquipped)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func slotCardView(for slot: SlotDefinition, equipped: EquippedItem?) -> some View {
        if let equipped {
            let marketplaceItem = equippedMarketplaceItem(equipped)
            let isUnequipping = unequippingItemType == slot.type

            if isUnequipping {
                VStack(spacing: 8) {
                    AppDepthSurface(
                        shape: .roundedRectangle(cornerRadius: 16),
                        surfaceColor: AppColors.surface,
                        borderColor: AppColors.outline.opacity(0.12),
                        depthColor: AppColors.outline.opacity(0.16),
                        borderWidth: 1.5,
                        depthOffset: 4,
                        contentInsets: EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                    ) {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 76)
                    }

                    VStack(spacing: 2) {
                        Text(marketplaceItem.name)
                            .font(AppFonts.subheadlineBold)
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)

                        Text(slot.displayName)
                            .font(AppFonts.caption2Bold)
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .frame(height: 46, alignment: .top)
                }
            } else {
                InventoryItemCard(
                    title: marketplaceItem.name,
                    category: slot.displayName,
                    itemCategory: marketplaceItem.category,
                    imageURL: marketplaceItem.imageURL,
                    symbolName: marketplaceItem.symbolName,
                    state: .equipped,
                    onTap: {
                        onSelect(marketplaceItem)
                    }
                )
            }
        } else {
            InventoryItemCard(
                title: slot.displayName,
                category: slot.emptyMessage,
                imageURL: nil,
                placeholderImageName: slot.placeholderImageName,
                state: .empty,
                onTap: nil
            )
        }
    }

    private func equippedMarketplaceItem(_ equipped: EquippedItem) -> MarketplaceItem {
        var item = MarketplaceItem(storeItem: equipped.item)
        item.status = .equipped
        return item
    }
}

#Preview("Profile Equipped Items Section") {
    ProfileEquippedItemsSection(
        equippedItems: [],
        onSelect: { _ in }
    )
    .padding()
    .background(AppColors.screenBackground)
}

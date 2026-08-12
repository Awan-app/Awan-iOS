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
    let onUnequip: (MarketplaceItem) -> Void

    private struct SlotDefinition {
        let type: StoreItemType
        let displayName: String
        let defaultSymbol: String
    }

    private let fixedSlots: [SlotDefinition] = [
        SlotDefinition(type: .frame, displayName: L10n.Marketplace.filterFrames, defaultSymbol: "square.on.circle"),
        SlotDefinition(type: .skin, displayName: L10n.Marketplace.filterSkins, defaultSymbol: "paintpalette.fill"),
        SlotDefinition(type: .theme, displayName: L10n.Marketplace.filterThemes, defaultSymbol: "globe"),
        SlotDefinition(type: .icon, displayName: L10n.Marketplace.filterAppIcons, defaultSymbol: "square.grid.2x2.fill")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(
                title: L10n.Profile.equippedItems,
                accentColor: AppColors.accentGreen
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(fixedSlots, id: \.displayName) { slot in
                        let matchingEquipped = equippedItems.first { item in
                            slot.type == item.type
                        }

                        slotCardView(for: slot, equipped: matchingEquipped)
                            .frame(width: 90)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func slotCardView(for slot: SlotDefinition, equipped: EquippedItem?) -> some View {
        if let equipped {
            let marketplaceItem = MarketplaceItem(storeItem: equipped.item)
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
                    imageURL: marketplaceItem.imageURL,
                    symbolName: marketplaceItem.symbolName,
                    state: .equipped,
                    onTap: nil,
                    onCheckmarkTap: {
                        onUnequip(marketplaceItem)
                    }
                )
            }
        } else {
            InventoryItemCard(
                title: slot.displayName,
                category: L10n.Marketplace.emptySubtitle,
                imageURL: nil,
                symbolName: slot.defaultSymbol,
                state: .empty,
                onTap: nil
            )
        }
    }
}

#Preview("Profile Equipped Items Section") {
    ProfileEquippedItemsSection(
        equippedItems: [],
        onUnequip: { _ in }
    )
    .padding()
    .background(AppColors.screenBackground)
}

//
//  ProfileEquippedItemsSection.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct ProfileEquippedItemsSection: View {
    let equippedItems: [EquippedItem]
    var unequippingItemType: String? = nil
    let onUnequip: (MarketplaceItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(
                title: L10n.Profile.equippedItems,
                accentColor: AppColors.accentGreen
            )

            if equippedItems.isEmpty {
                AppDepthSurface(
                    shape: .roundedRectangle(cornerRadius: 18),
                    surfaceColor: AppColors.surface,
                    borderColor: AppColors.outline.opacity(0.12),
                    depthColor: AppColors.outline.opacity(0.16),
                    borderWidth: 1.5,
                    depthOffset: 4,
                    contentInsets: EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
                ) {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(AppColors.textSecondary)
                        Text(L10n.Marketplace.equippedHint)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(equippedItems) { equipped in
                            let marketplaceItem = MarketplaceItem(storeItem: equipped.item)
                            equippedCard(for: equipped, marketplaceItem: marketplaceItem)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func equippedCard(for equipped: EquippedItem, marketplaceItem: MarketplaceItem) -> some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 18),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.accentGreen.opacity(0.40),
            depthColor: AppColors.accentGreenDepth.opacity(0.35),
            borderWidth: 1.5,
            depthOffset: 4,
            contentInsets: EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
        ) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(categoryColor(for: marketplaceItem).opacity(0.12))
                            .frame(width: 38, height: 38)
                        Image(systemName: marketplaceItem.symbolName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(categoryColor(for: marketplaceItem))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(marketplaceItem.name)
                            .font(AppFonts.subheadlineBold)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)
                        Text(equipped.type)
                            .font(AppFonts.caption2Bold)
                            .foregroundStyle(categoryColor(for: marketplaceItem))
                    }
                }

                let isItemUnequipping = (unequippingItemType?.uppercased() == equipped.type.uppercased())
                if isItemUnequipping {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 32)
                } else {
                    Button {
                        onUnequip(marketplaceItem)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 12, weight: .bold))
                            Text(L10n.Marketplace.unequip)
                                .font(AppFonts.caption2Bold)
                        }
                        .foregroundStyle(AppColors.warning)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(AppColors.warning.opacity(0.12))
                        )
                        .overlay(
                            Capsule().stroke(AppColors.warning.opacity(0.25), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: 170)
        }
    }

    private func categoryColor(for item: MarketplaceItem) -> Color {
        switch item.category {
        case .frames:   return AppColors.accentBlue
        case .skins:    return AppColors.accentPurple
        case .themes:   return AppColors.accentGreen
        case .appIcons: return AppColors.warning
        case .all:      return AppColors.textSecondary
        }
    }
}

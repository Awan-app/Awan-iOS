//
//  MarketplaceCategoryChips.swift
//  Presentation
//

import Common
import SwiftUI

struct MarketplaceCategoryChips: View {
    @Binding var selectedCategory: MarketplaceItemCategory

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MarketplaceItemCategory.allCases) { category in
                    let isSelected = selectedCategory == category
                    Button {
                        withAnimation(.snappy(duration: 0.2)) {
                            selectedCategory = category
                        }
                    } label: {
                        Text(title(for: category))
                            .font(isSelected ? AppFonts.subheadlineHeavy : AppFonts.subheadlineSemibold)
                            .foregroundStyle(isSelected ? AppColors.onAccent : AppColors.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 9)
                    }
                    .buttonStyle(
                        AppDepthButtonStyle(
                            shape: .roundedRectangle(cornerRadius: 14),
                            surfaceColor: isSelected ? AppColors.accentBlue : AppColors.surface,
                            borderColor: isSelected ? AppColors.accentBlue : AppColors.outline.opacity(0.14),
                            depthColor: isSelected ? AppColors.accentBlueDepth : AppColors.outline.opacity(0.12),
                            borderWidth: 1.5,
                            depthOffset: isSelected ? 3 : 2,
                            pressedOffset: 1
                        )
                    )
                    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
                }
            }
            .padding(.horizontal, 2)
            .padding(.bottom, 4)
        }
    }

    private func title(for category: MarketplaceItemCategory) -> String {
        switch category {
        case .all:      return L10n.Marketplace.filterAll
        case .frames:   return L10n.Marketplace.filterFrames
        case .skins:    return L10n.Marketplace.filterSkins
        case .themes:   return L10n.Marketplace.filterThemes
        case .appIcons: return L10n.Marketplace.filterAppIcons
        }
    }
}

#Preview("Category Chips Light") {
    MarketplaceCategoryChips(selectedCategory: .constant(.all))
        .padding()
        .background(AppColors.screenBackground)
}

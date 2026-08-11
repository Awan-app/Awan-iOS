//
//  ProfileLockedItemsSection.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct ProfileLockedItemsSection: View {
    let lockedItems: [MarketplaceItem]
    let onItemTap: (MarketplaceItem) -> Void

    var body: some View {
        if !lockedItems.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 4) {
//                    Image(systemName: "lock.fill")
//                        .font(.system(size: 14, weight: .bold))
//                        .foregroundStyle(AppColors.textSecondary)
//                        .offset(y: -3)

                    SectionHeaderLabel(
                        title: "\(L10n.Profile.lockedItems) (\(lockedItems.count))",
                        accentColor: AppColors.textSecondary
                    )
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(lockedItems) { item in
                            InventoryItemCard(item: item)
                                .frame(width: 90)
                        }
                    }
                    .padding(.bottom, 6)
                }
            }
        }
    }
}

#Preview("Locked Items Section") {
    let lockedItems = [
        MarketplaceItem(
            name: "Diamond Frame",
            description: "A sparkling diamond frame.",
            category: .frames,
            status: .locked,
            symbolName: "app.dashed"
        ),
        MarketplaceItem(
            name: "Very Long Cyberpunk Theme Name",
            description: "A futuristic cyberpunk theme.",
            category: .themes,
            status: .locked,
            symbolName: "globe"
        ),
        MarketplaceItem(
            name: "Robot Avatar",
            description: "A cool robot skin.",
            category: .skins,
            status: .locked,
            symbolName: "paintpalette.fill"
        ),
    ]

    VStack {
        ProfileLockedItemsSection(lockedItems: lockedItems, onItemTap: { _ in })
    }
    .padding()
    .background(AppColors.screenBackground)
}

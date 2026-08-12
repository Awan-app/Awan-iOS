//
//  InventoryItemCard.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

public enum InventoryItemCardState: Equatable, Sendable {
    case equipped
    case owned
    case locked
    case empty
}

public struct InventoryItemCard: View {
    public let title: String
    public let category: String
    public let imageURL: String?
    public let symbolName: String
    public let placeholderImageName: String?
    public let state: InventoryItemCardState
    public let onTap: (() -> Void)?
    public let onCheckmarkTap: (() -> Void)?

    public init(
        title: String,
        category: String,
        imageURL: String? = nil,
        symbolName: String = "sparkles",
        placeholderImageName: String? = nil,
        state: InventoryItemCardState = .owned,
        onTap: (() -> Void)? = nil,
        onCheckmarkTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.category = category
        self.imageURL = imageURL
        self.symbolName = symbolName
        self.placeholderImageName = placeholderImageName
        self.state = state
        self.onTap = (state == .locked || state == .empty) ? nil : onTap
        self.onCheckmarkTap = onCheckmarkTap
    }

    public init(
        item: MarketplaceItem,
        overrideState: InventoryItemCardState? = nil,
        onTap: (() -> Void)? = nil,
        onCheckmarkTap: (() -> Void)? = nil
    ) {
        let cardState: InventoryItemCardState
        if let overrideState {
            cardState = overrideState
        } else {
            switch item.status {
            case .equipped:
                cardState = .equipped
            case .owned, .price:
                cardState = .owned
            case .locked:
                cardState = .locked
            }
        }

        self.init(
            title: item.name,
            category: item.category.rawValue.capitalized,
            imageURL: item.imageURL,
            symbolName: item.symbolName,
            state: cardState,
            onTap: onTap,
            onCheckmarkTap: onCheckmarkTap
        )
    }

    public init(
        equipped: EquippedItem,
        onTap: (() -> Void)? = nil,
        onCheckmarkTap: (() -> Void)? = nil
    ) {
        let item = MarketplaceItem(storeItem: equipped.item)
        self.init(
            title: item.name,
            category: equipped.type.rawValue,
            imageURL: item.imageURL,
            symbolName: item.symbolName,
            state: .equipped,
            onTap: onTap,
            onCheckmarkTap: onCheckmarkTap
        )
    }

    public var body: some View {
        if let onTap {
            Button(action: onTap) {
                cardContent
            }
            .buttonStyle(.plain)
        } else {
            cardContent
        }
    }

    private var cardContent: some View {
        VStack(spacing: 8) {
            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 16),
                surfaceColor: AppColors.surface,
                borderColor: state == .equipped ? AppColors.accentGreen.opacity(0.40)
                :state == .owned ? AppColors.accentBlue.opacity(0.40)
                :AppColors.outline.opacity(0.12),
                depthColor: state == .equipped ? AppColors.accentGreenDepth.opacity(0.35) : AppColors.outline.opacity(0.16),
                borderWidth: 1.5,
                depthOffset: 4,
                contentInsets: EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            ) {
                ZStack(alignment: .center) {
                    previewImage

                    if state == .locked {
                        lockOverlay
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 76)
                .overlay(alignment: .topTrailing) {
                    if state == .equipped {
                        if let onCheckmarkTap {
                            Button {
                                onCheckmarkTap()
                            } label: {
                                checkBadge
                            }
                            .buttonStyle(.plain)
                            .offset(x: 4, y: -4)
                        } else {
                            checkBadge
                                .offset(x: 4, y: -4)
                        }
                    }
                }
            }

            VStack(spacing: 2) {
                Text(title)
                    .font(AppFonts.subheadlineBold)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(category)
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .frame(height: 50, alignment: .top)
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel(title)
        .accessibilityAddTraits((state == .locked || state == .empty) ? [] : .isButton)
    }

    @ViewBuilder
    private var previewImage: some View {
        AppRemoteImage(urlString: imageURL) {
            symbolFallback
        }
        .saturation(state == .locked ? 0 : 1)
        .opacity(state == .locked ? 0.55 : 1.0)
    }

    private var symbolFallback: some View {
        Group {
            if let placeholderImageName {
                Image(placeholderImageName, bundle: .module)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: symbolName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle((state == .locked || state == .empty) ? AppColors.textSecondary : AppColors.accentBlue)
            }
        }
        .padding(6)
    }

    private var checkBadge: some View {
        ZStack {
            Circle()
                .fill(AppColors.accentGreen)
                .frame(width: 22, height: 22)

            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(AppColors.onAccent)
        }
    }

    private var lockOverlay: some View {
        ZStack {
            Circle()
                .fill(AppColors.surface.opacity(0.90))
                .frame(width: 34, height: 34)

            Image(systemName: "lock.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview("Inventory Item Card") {
    HStack(spacing: 16) {
        InventoryItemCard(
            title: "Cloud Frame",
            category: "Frame",
            symbolName: "cloud.fill",
            state: .equipped
        )

        InventoryItemCard(
            title: "Pink Frame",
            category: "Frame",
            symbolName: "square",
            state: .owned
        )

        InventoryItemCard(
            title: "Diamond Frame",
            category: "Frame",
            symbolName: "diamond",
            state: .locked
        )
    }
    .padding()
    .background(AppColors.screenBackground)
}

import Common
import SwiftUI

struct MarketplaceItemCard: View {
    let item: MarketplaceItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 20),
                surfaceColor: AppColors.surface,
                borderColor: AppColors.outline.opacity(0.10),
                depthColor: AppColors.outline.opacity(0.14),
                borderWidth: 1.5,
                depthOffset: 4,
                contentInsets: EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    ZStack(alignment: .topTrailing) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(imageBackground)
                                .frame(maxWidth: .infinity)
                                .frame(height: 90)

                            if let imageURLString = item.imageURL, let url = URL(string: imageURLString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .padding(8)
                                    case .failure, .empty:
                                        Image(systemName: item.symbolName)
                                            .font(.system(size: 42, weight: .bold))
                                            .foregroundStyle(imageForeground)
                                    @unknown default:
                                        Image(systemName: item.symbolName)
                                            .font(.system(size: 42, weight: .bold))
                                            .foregroundStyle(imageForeground)
                                    }
                                }
                            } else {
                                Image(systemName: item.symbolName)
                                    .font(.system(size: 42, weight: .bold))
                                    .foregroundStyle(imageForeground)
                            }
                        }

                        if item.isNew {
                            Text(L10n.Marketplace.badgeNew)
                                .font(AppFonts.caption2Bold)
                                .foregroundStyle(AppColors.onAccent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(AppColors.accentPurple)
                                )
                                .padding(6)
                        }
                    }

                    Text(categoryTitle)
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(categoryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(categoryColor.opacity(0.12))
                        )
                        .overlay(
                            Capsule()
                                .stroke(categoryColor.opacity(0.25), lineWidth: 1.0)
                        )

                    Text(item.name)
                        .font(AppFonts.subheadlineBold)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    statusBadge
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.name)
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch item.status {
        case let .price(pts):
            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 12),
                surfaceColor: AppColors.surface,
                borderColor: AppColors.reward.opacity(0.50),
                depthColor: AppColors.reward.opacity(0.35),
                borderWidth: 1.5,
                depthOffset: 3,
                contentInsets: EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
            ) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(AppColors.reward)
                    Text("\(pts) \(L10n.Marketplace.pts)")
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.textPrimary)
                }
            }

        case .owned:
            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 12),
                surfaceColor: AppColors.surface,
                borderColor: AppColors.outline.opacity(0.22),
                depthColor: AppColors.outline.opacity(0.16),
                borderWidth: 1.5,
                depthOffset: 3,
                contentInsets: EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
            ) {
                Text(L10n.Marketplace.statusOwned)
                    .font(AppFonts.subheadlineSemibold)
                    .foregroundStyle(AppColors.textSecondary)
            }

        case .equipped:
            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 12),
                surfaceColor: AppColors.surface,
                borderColor: AppColors.accentGreen.opacity(0.55),
                depthColor: AppColors.accentGreenDepth.opacity(0.40),
                borderWidth: 1.5,
                depthOffset: 3,
                contentInsets: EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
            ) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColors.accentGreen)
                    Text(L10n.Marketplace.statusEquipped)
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.accentGreen)
                }
            }

        case .locked:
            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 12),
                surfaceColor: AppColors.surface,
                borderColor: AppColors.outline.opacity(0.20),
                depthColor: AppColors.outline.opacity(0.15),
                borderWidth: 1.5,
                depthOffset: 3,
                contentInsets: EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
            ) {
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColors.textSecondary)
                    Text(L10n.Marketplace.statusLocked)
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }

    private var categoryTitle: String {
        switch item.category {
        case .all:      return ""
        case .frames:   return L10n.Marketplace.filterFrames
        case .skins:    return L10n.Marketplace.filterSkins
        case .themes:   return L10n.Marketplace.filterThemes
        case .appIcons: return L10n.Marketplace.filterAppIcons
        }
    }

    private var categoryColor: Color {
        switch item.category {
        case .frames:   return AppColors.accentBlue
        case .skins:    return AppColors.accentPurple
        case .themes:   return AppColors.accentGreen
        case .appIcons: return AppColors.warning
        case .all:      return AppColors.textSecondary
        }
    }

    private var imageBackground: Color {
        switch item.category {
        case .frames:   return AppColors.accentBlue.opacity(0.10)
        case .skins:    return AppColors.accentPurple.opacity(0.10)
        case .themes:   return AppColors.accentGreen.opacity(0.10)
        case .appIcons: return AppColors.warning.opacity(0.10)
        case .all:      return AppColors.infoSurface
        }
    }

    private var imageForeground: Color {
        switch item.category {
        case .frames:   return AppColors.accentBlue
        case .skins:    return AppColors.accentPurple
        case .themes:   return AppColors.accentGreen
        case .appIcons: return AppColors.warning
        case .all:      return AppColors.textSecondary
        }
    }
}

#Preview("Item Card Grid Light") {
    let items = [
        MarketplaceItem(
            name: "Cloud Halo Frame",
            description: "A fluffy cloud halo.",
            category: .frames,
            status: .price(250),
            symbolName: "cloud.circle.fill"
        ),
        MarketplaceItem(
            name: "Neon Ring Frame",
            description: "A neon ring.",
            category: .frames,
            status: .equipped,
            symbolName: "record.circle.fill"
        ),
    ]
    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(items) { item in
                MarketplaceItemCard(item: item, onTap: {})
            }
        }
        .padding()
    }
    .background(AppColors.screenBackground)
}

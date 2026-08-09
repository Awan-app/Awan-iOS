import Common
import SwiftUI

struct MarketplaceItemDetailSheet: View {
    let item: MarketplaceItem
    let userPoints: Int
    var isPurchasing: Bool = false
    var purchaseFeedback: PurchaseFeedback? = nil
    var onBuy: () -> Void = {}
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // Sheet content
            ZStack(alignment: .topTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.35))
                            .frame(width: 38, height: 4)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 12)
                            .padding(.bottom, 8)

                        heroImage

                        Text(categoryTitle)
                            .font(AppFonts.captionHeavy)
                            .foregroundStyle(categoryColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(categoryColor.opacity(0.12)))
                            .overlay(Capsule().stroke(categoryColor.opacity(0.25), lineWidth: 1.2))

                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.name)
                                .font(AppFonts.title2Black)
                                .foregroundStyle(AppColors.textPrimary)
                            Text(item.description)
                                .font(AppFonts.body)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        statusCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(
                    AppDepthButtonStyle(
                        shape: .roundedRectangle(cornerRadius: 12),
                        surfaceColor: AppColors.surface,
                        borderColor: AppColors.outline.opacity(0.18),
                        depthColor: AppColors.outline.opacity(0.14),
                        borderWidth: 1.5,
                        depthOffset: 3,
                        pressedOffset: 2
                    )
                )
                .padding(.top, 16)
                .padding(.trailing, 20)
            }
            .background(AppColors.surface, ignoresSafeAreaEdges: .all)

            // Purchase feedback banner — rendered above sheet content
            if let feedback = purchaseFeedback {
                MarketplacePurchaseFeedbackBanner(feedback: feedback)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.42, dampingFraction: 0.75), value: feedback)
                    .padding(.bottom, 24)
            }
        }
    }

    @ViewBuilder
    private var heroImage: some View {
        ZStack {
            LinearGradient(
                colors: [heroPrimaryColor.opacity(0.15), AppColors.screenBackground],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            if case .locked = item.status {
                Image(systemName: item.symbolName)
                    .font(.system(size: 90, weight: .bold))
                    .foregroundStyle(heroPrimaryColor)
                    .blur(radius: 12)
                    .overlay(
                        Image(systemName: "lock.fill")
                            .font(.system(size: 44, weight: .black))
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.35), radius: 8, y: 4)
                    )
            } else {
                Image(systemName: item.symbolName)
                    .font(.system(size: 90, weight: .bold))
                    .foregroundStyle(heroPrimaryColor)
                    .shadow(color: heroPrimaryColor.opacity(0.30), radius: 20, y: 8)
            }
        }
    }

    @ViewBuilder
    private var statusCard: some View {
        switch item.status {
        case let .price(pts):
            if userPoints >= pts {
                MarketplaceDetailAffordableCard(
                    pts: pts,
                    userPoints: userPoints,
                    isPurchasing: isPurchasing,
                    onBuy: onBuy
                )
            } else {
                MarketplaceDetailNotEnoughCard(pts: pts, userPoints: userPoints)
            }
        case .owned:
            MarketplaceDetailOwnedCard()
        case .equipped:
            MarketplaceDetailEquippedCard()
        case .locked:
            MarketplaceDetailLockedCard()
        }
    }

    private var categoryTitle: String {
        switch item.category {
        case .frames:   return L10n.Marketplace.filterFrames
        case .skins:    return L10n.Marketplace.filterSkins
        case .themes:   return L10n.Marketplace.filterThemes
        case .appIcons: return L10n.Marketplace.filterAppIcons
        case .all:      return ""
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

    private var heroPrimaryColor: Color {
        switch item.category {
        case .frames:   return AppColors.accentBlue
        case .skins:    return AppColors.accentPurple
        case .themes:   return AppColors.accentGreen
        case .appIcons: return AppColors.warning
        case .all:      return AppColors.accentBlue
        }
    }
}

#Preview("Affordable") {
    let item = MarketplaceItem(
        name: "Wizard Cloud", description: "A magical skin.",
        category: .skins, status: .price(200), symbolName: "cloud.fill", isNew: true
    )
    Color.gray.opacity(0.3).ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            MarketplaceItemDetailSheet(item: item, userPoints: 1_240, onDismiss: {})
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
}

#Preview("Not Enough Points") {
    let item = MarketplaceItem(
        name: "Sunset Theme", description: "Warm hues.",
        category: .themes, status: .price(1_500), symbolName: "sunset.fill"
    )
    Color.gray.opacity(0.3).ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            MarketplaceItemDetailSheet(item: item, userPoints: 800, onDismiss: {})
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
}

#Preview("Owned") {
    let item = MarketplaceItem(
        name: "Neon Frame", description: "Owned!",
        category: .frames, status: .owned, symbolName: "record.circle.fill"
    )
    Color.gray.opacity(0.3).ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            MarketplaceItemDetailSheet(item: item, userPoints: 1_240, onDismiss: {})
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
}

#Preview("Equipped") {
    let item = MarketplaceItem(
        name: "Neon Ring", description: "Vibrant ring.",
        category: .frames, status: .equipped, symbolName: "record.circle.fill"
    )
    Color.gray.opacity(0.3).ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            MarketplaceItemDetailSheet(item: item, userPoints: 1_240, onDismiss: {})
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
}

#Preview("Locked") {
    let item = MarketplaceItem(
        name: "Sleepy Cloud", description: "Cozy skin.",
        category: .skins, status: .locked, symbolName: "moon.zzz.fill"
    )
    Color.gray.opacity(0.3).ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            MarketplaceItemDetailSheet(item: item, userPoints: 1_240, onDismiss: {})
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
}

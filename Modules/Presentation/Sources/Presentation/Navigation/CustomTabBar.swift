//
//  CustomTabBar.swift
//  Presentation
//

import Common
import SwiftUI

// MARK: - CustomTabBar

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    var onAddTapped: () -> Void = {}

    @Namespace private var tabPillNamespace

    private let leading: [(MainTab, String)] = [
        (.home, "house.fill"),
        (.tasks, "tray.fill")
    ]
    private let trailing: [(MainTab, String)] = [
        (.store, "storefront.fill"),
        (.you, "person.fill")
    ]

    var body: some View {
        ZStack(alignment: .top) {


            HStack(spacing: 0) {
                ForEach(leading, id: \.0) { (tab, icon) in
                    tabIcon(tab: tab, icon: icon)
                }

                Color.clear
                    .frame(width: 76, height: 1)

                ForEach(trailing, id: \.0) { (tab, icon) in
                    tabIcon(tab: tab, icon: icon)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background {

                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.ultraThinMaterial)


                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(AppColors.surface.opacity(0.55))
            }
            .overlay {
                // Uniform crisp blue border
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(
                        AppColors.accentBlue.opacity(0.55),
                        lineWidth: 1.75
                    )
            }


            Button(action: onAddTapped) {
                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppColors.onAccent)
                    .frame(width: 54, height: 54)
            }
            .buttonStyle(
                AppDepthButtonStyle(
                    shape: .roundedRectangle(cornerRadius: 18),
                    surfaceColor: AppColors.accentBlue,
                    borderColor: AppColors.onAccent.opacity(0.35),
                    depthColor: AppColors.accentBlueDepth,
                    borderWidth: 1.5,
                    depthOffset: 7,
                    pressedOffset: 5
                )
            )
            .accessibilityLabel(L10n.Home.btnPlanItForMe)
            .offset(y: -4)
        }
        .padding(.horizontal, 16)
    }

    // MARK: – Creative Icon Tab Button

    private func tabIcon(tab: MainTab, icon: String) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.54)) {
                selectedTab = tab
            }
        } label: {
            ZStack {

                if isSelected {
                    VStack(spacing: 3) {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppColors.accentBlue.opacity(0.18),
                                        AppColors.accentBlue.opacity(0.08)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 50, height: 38)


                        Circle()
                            .fill(AppColors.accentBlue)
                            .frame(width: 4, height: 4)
                    }
                    .matchedGeometryEffect(id: "active_tab_glow", in: tabPillNamespace)
                }

                Image(systemName: icon)
                    .font(.system(size: 22, weight: isSelected ? .bold : .regular))
                    .foregroundStyle(
                        isSelected ? AppColors.accentBlue : AppColors.textSecondary.opacity(0.5)
                    )
                    .scaleEffect(isSelected ? 1.25 : 1.0)
                    .offset(y: isSelected ? -3 : 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tabTitle(tab))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private func tabTitle(_ tab: MainTab) -> String {
        switch tab {
        case .home:    return L10n.Home.today
        case .tasks:   return L10n.Inbox.title
        case .rewards: return L10n.Home.rewards
        case .you:     return L10n.Home.you
        default:       return ""
        }
    }
}

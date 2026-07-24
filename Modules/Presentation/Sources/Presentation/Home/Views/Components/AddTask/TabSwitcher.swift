import Common
import SwiftUI

struct TabSwitcher: View {
    public enum Tab: String, CaseIterable, Identifiable {
        case quickAdd
        case manual

        public var id: String { rawValue }
    }

    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 4) {
            tabButton(
                title: L10n.Home.tabWithAwan,
                icon: "sparkles",
                tab: .quickAdd
            )
            tabButton(
                title: L10n.Home.tabManual,
                icon: "line.3.horizontal",
                tab: .manual
            )
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: AppColors.accentBlue.opacity(0.08), radius: 8, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.accentBlue.opacity(0.18), lineWidth: 1)
        )
    }

    private func tabButton(title: String, icon: String, tab: Tab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isSelected ? .white : AppColors.accentBlue)

                Text(title)
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundStyle(isSelected ? .white : AppColors.brandDarkBlue)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppColors.accentBlue)
                        .shadow(color: AppColors.accentBlue.opacity(0.3), radius: 4, y: 2)
                }
            }
            .overlay {
                if !isSelected {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppColors.accentBlue.opacity(0.4), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

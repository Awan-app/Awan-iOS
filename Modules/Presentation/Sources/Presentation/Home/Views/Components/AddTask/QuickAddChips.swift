import Common
import SwiftUI

struct QuickAddChips: View {
    var body: some View {
        HStack(spacing: 6) {
            infoChip(
                title: L10n.Home.chipSmartDuration,
                icon: "sparkles"
            )
            infoChip(
                title: L10n.Home.chipBestZone,
                icon: "cloud"
            )
            infoChip(
                title: L10n.Home.chipAutoScheduled,
                icon: "arrow.up.right"
            )
        }
    }

    private func infoChip(title: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppColors.accentBlue)

            Text(title)
                .font(.system(size: 10.5, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.brandDarkBlue)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .shadow(
                    color: AppColors.accentBlue.opacity(0.12),
                    radius: 5, x: 0, y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppColors.accentBlue.opacity(0.5), lineWidth: 1.5)
        )
    }
}

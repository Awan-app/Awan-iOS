import Common
import SwiftUI

struct SessionDetailsStatusView: View {
    let status: String
    let isLocked: Bool
    let lockLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Home.sessionDetails)
                .font(AppFonts.captionBlack)
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)

            HStack(spacing: 10) {
                SessionDetailsInfoChip(
                    title: status,
                    icon: "clock.fill",
                    foregroundColor: AppColors.accentBlue,
                    surfaceColor: AppColors.infoSurface,
                    depthColor: AppColors.accentBlueDepth.opacity(0.35)
                )

                SessionDetailsInfoChip(
                    title: lockLabel,
                    icon: isLocked ? "lock.fill" : "lock.open.fill",
                    foregroundColor: AppColors.textSecondary,
                    surfaceColor: AppColors.surface,
                    depthColor: AppColors.outline.opacity(0.16)
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

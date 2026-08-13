import Common
import SwiftUI

struct SessionDetailsStatusView: View {
    let status: SessionDetailsStatusUIModel
    let isLocked: Bool
    let lockLabel: String

    var body: some View {

            HStack(spacing: 10) {
                Text(L10n.Home.sessionDetails)
                    .font(AppFonts.captionBlack)
                    .foregroundStyle(AppColors.textSecondary)
                    .textCase(.uppercase)
                Spacer()
                SessionDetailsInfoChip(
                    title: status.title,
                    icon: status.icon,
                    foregroundColor: status.foregroundColor,
                    surfaceColor: status.surfaceColor,
                    depthColor: status.depthColor,
                    borderColor: status.borderColor,
                    borderWidth: 1
                )

                SessionDetailsInfoChip(
                    title: lockLabel,
                    icon: isLocked ? "lock.fill" : "lock.open.fill",
                    foregroundColor: AppColors.textSecondary,
                    surfaceColor: AppColors.surface,
                    depthColor: AppColors.outline.opacity(0.16)
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

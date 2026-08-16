import Common
import Domain
import SwiftUI

struct TaskDetailsHeaderView: View {
    let task: AwanTask
    let remainingRewardPoints: Int
    let areAllSessionRewardsClaimed: Bool
    let totalDurationMinutes: Int
    let onClose: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(AppFonts.captionIconBlack)
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(width: 38, height: 38)
                }
                .buttonStyle(AppDepthButtonStyle(
                    surfaceColor: AppColors.surface,
                    borderColor: AppColors.outline.opacity(0.12),
                    depthColor: AppColors.outline.opacity(0.16),
                    depthOffset: 3
                ))
                .accessibilityLabel(L10n.Common.close)

                SessionDetailsInfoChip(
                    title: rewardTitle,
                    icon: areAllSessionRewardsClaimed ? "checkmark" : "star.fill",
                    foregroundColor: AppColors.reward,
                    surfaceColor: AppColors.surface,
                    depthColor: AppColors.reward,
                    borderColor: AppColors.reward,
                    borderWidth: 1.5
                )

                SessionDetailsInfoChip(
                    title: durationTitle,
                    icon: "clock.fill",
                    foregroundColor: AppColors.accentBlue,
                    surfaceColor: AppColors.surface,
                    depthColor: AppColors.accentBlueDepth,
                    borderColor: AppColors.accentBlue,
                    borderWidth: 1.5
                )

                Spacer(minLength: 2)

                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(AppFonts.bodyBold)
                        .foregroundStyle(AppColors.destructive)
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(AppDepthButtonStyle(
                    surfaceColor: AppColors.surface,
                    borderColor: AppColors.destructive,
                    depthColor: AppColors.destructive,
                    borderWidth: 1.5,
                    depthOffset: 4
                ))
                .accessibilityLabel(L10n.Inbox.deleteTask)
            }

            Text(L10n.TaskDetails.title)
                .font(AppFonts.title2Black)
                .foregroundStyle(AppColors.textPrimary)
        }
    }

    private var rewardTitle: String {
        areAllSessionRewardsClaimed
            ? L10n.Inbox.pointsClaimed
            : L10n.Home.pointsValue(remainingRewardPoints)
    }

    private var durationTitle: String {
        let hours = totalDurationMinutes / 60
        let minutes = totalDurationMinutes % 60
        return hours > 0
            ? L10n.TaskDetails.hoursMinutes(hours, minutes)
            : L10n.TaskDetails.minutes(minutes)
    }
}

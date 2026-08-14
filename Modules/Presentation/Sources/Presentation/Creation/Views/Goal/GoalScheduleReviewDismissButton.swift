import Common
import SwiftUI

struct GoalScheduleReviewDismissButton: View {
    let onDismiss: () -> Void

    var body: some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark")
                .font(AppFonts.captionIconBlack)
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 38, height: 38)
        }
        .buttonStyle(
            AppDepthButtonStyle(
                surfaceColor: AppColors.surface,
                borderColor: AppColors.outline.opacity(0.12),
                depthColor: AppColors.outline.opacity(0.16),
                depthOffset: 3
            )
        )
        .accessibilityLabel(L10n.Common.close)
    }
}

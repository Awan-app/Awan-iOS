import Common
import Domain
import SwiftUI

struct TaskDetailsGoalSection: View {
    let goal: Goal?
    let onAdd: () -> Void
    let onRemove: () -> Void

    var body: some View {
        TaskDetailsSectionCard(title: L10n.TaskDetails.goal) {
            if let goal {
                HStack(spacing: 12) {
                    Image(systemName: "flag.fill")
                        .foregroundStyle(AppColors.warning)
                    Text(goal.name)
                        .font(AppFonts.bodyBold)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    Button(action: onRemove) {
                        Image(systemName: "xmark")
                            .font(AppFonts.caption2Bold)
                            .foregroundStyle(AppColors.destructive)
                            .frame(width: 34, height: 34)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(L10n.TaskDetails.removeGoal)
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.TaskDetails.noGoal)
                        .font(AppFonts.bodySemibold)
                        .foregroundStyle(AppColors.textSecondary)
                    AppButton(
                        title: L10n.TaskDetails.addToGoal,
                        icon: "folder.badge.plus",
                        color: AppColors.accentBlue,
                        onTap: onAdd
                    )
                }
            }
        }
    }
}

import Common
import SwiftUI

struct HomePlanSummaryView: View {
    let taskCount: Int
    let scheduledMinutes: Int
    let completedCount: Int
    let totalCount: Int
    let taskAllocations: [HomeTaskAllocationItem]
    let onAddTask: () -> Void
    let onAddGoal: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.Home.todaysPlan)
                        .font(AppFonts.title3Black)
                        .foregroundStyle(AppColors.brandDarkBlue)
                    Text(L10n.Home.taskScheduleSummary(taskCount, durationText))
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                Text(L10n.Home.completionSummary(completedCount, totalCount))
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundStyle(AppColors.textSecondary)
            }

            allocationBar

            HStack(spacing: 14) {
                AppButton(
                    title: L10n.Home.addTask,
                    icon: "plus",
                    color: AppColors.accentBlue,
                    onTap: onAddTask
                )
                .accessibilityIdentifier("add-task-button")

                AppButton(
                    title: L10n.Home.addGoal,
                    icon: "plus",
                    color: AppColors.accentPurple,
                    onTap: onAddGoal
                )
                .accessibilityIdentifier("add-goal-button")
            }
        }
        .padding(18)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppColors.outline.opacity(0.08), lineWidth: 1.5)
        }
        .shadow(color: AppColors.shadow.opacity(0.09), radius: 15, y: 7)
    }

    private var allocationBar: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 4
            let gapWidth = spacing * CGFloat(max(0, taskAllocations.count - 1))
            let availableWidth = max(0, geometry.size.width - gapWidth)

            ZStack(alignment: .leading) {
                Capsule().fill(AppColors.divider)

                HStack(spacing: spacing) {
                    ForEach(taskAllocations) { allocation in
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(allocation.color.gradient)
                            .frame(
                                width: availableWidth * CGFloat(allocation.taskCount) / CGFloat(max(1, taskCount))
                            )
                            .shadow(color: allocation.color.opacity(0.28), radius: 2, y: 1)
                    }
                }
            }
            .clipShape(Capsule())
        }
        .frame(height: 11)
        .animation(.easeInOut(duration: 0.25), value: taskAllocations)
    }

    private var durationText: String {
        let hours = scheduledMinutes / 60
        let minutes = scheduledMinutes % 60
        if hours == 0 { return L10n.Home.minutesShort(minutes) }
        if minutes == 0 { return L10n.Home.hoursShort(hours) }
        return L10n.Home.hoursMinutesShort(hours, minutes)
    }
}

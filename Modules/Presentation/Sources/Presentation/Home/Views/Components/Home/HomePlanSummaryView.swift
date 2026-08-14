import Common
import SwiftUI

struct HomePlanSummaryView: View {
    let taskCount: Int
    let scheduledMinutes: Int
    let completedCount: Int
    let totalCount: Int
    let taskAllocations: [HomeTaskAllocationItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.Home.todaysPlan)
                        .font(AppFonts.headlineBlack)
                        .foregroundStyle(AppColors.brandDarkBlue)
                    Text(L10n.Home.taskScheduleSummary(taskCount, durationText))
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer(minLength: 8)
                Text(L10n.Home.completionSummary(completedCount, totalCount))
                    .font(AppFonts.captionHeavy)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }

            allocationBar
        }
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
        .frame(height: 6)
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


#Preview {
    HomePlanSummaryView(taskCount: 5, scheduledMinutes: 120, completedCount: 2, totalCount: 5, taskAllocations: [])
        .padding()
}

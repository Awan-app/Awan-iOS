import Common
import SwiftUI

struct CalendarGoalCard: View {
    let goal: CalendarGoalUIModel

    var body: some View {
        AppDepthSurface {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "target")
                    .font(AppFonts.progressSymbol)
                    .foregroundStyle(AppColors.accentBlue)
                    .frame(width: 42, height: 42)
                    .background(AppColors.infoSurface, in: Circle())

                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.title)
                        .font(AppFonts.headlineBlack)
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let description = goal.description {
                        Text(description)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Label {
                        Text(goal.deadlineText)
                            .font(AppFonts.captionHeavy)
                    } icon: {
                        Image(systemName: "calendar.badge.clock")
                            .font(AppFonts.captionIconBlack)
                    }
                    .foregroundStyle(
                        goal.hasDeadline
                            ? AppColors.accentBlue
                            : AppColors.textSecondary
                    )
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        goal.hasDeadline
                            ? AppColors.infoSurface
                            : AppColors.screenBackground,
                        in: Capsule()
                    )
                }
            }
        }
    }
}

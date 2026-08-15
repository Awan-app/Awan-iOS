import Common
import SwiftUI

struct GoalScheduleReviewHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.GoalCreation.scheduleReviewTitle)
                .font(AppFonts.title2Black)
                .foregroundStyle(AppColors.brandDarkBlue)

            Text(L10n.GoalCreation.scheduleReviewSubtitle)
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }
}

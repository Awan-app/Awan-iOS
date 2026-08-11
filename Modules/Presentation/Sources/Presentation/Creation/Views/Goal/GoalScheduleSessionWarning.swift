import Common
import Domain
import SwiftUI

struct GoalScheduleSessionWarning: View {
    let session: GoalScheduleReviewSession

    @ViewBuilder
    var body: some View {
        switch session.kind {
        case .noZone(let reason):
            warningBox(
                title: L10n.GoalCreation.noZone,
                body: reason,
                detail: nil
            )
        case .overlap(let reason, let info):
            warningBox(
                title: session.isEdited
                    ? L10n.GoalCreation.originalConflict
                    : L10n.GoalCreation.acceptSuggestion,
                body: reason,
                detail: info.map(overlapDescription)
            )
        case .proposed, .manual:
            EmptyView()
        }
    }

    private func warningBox(
        title: String,
        body: String,
        detail: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(title, systemImage: "exclamationmark.triangle.fill")
                .font(AppFonts.captionHeavy)
            Text(body)
                .font(AppFonts.captionHeavy)
            if let detail {
                Text(detail)
                    .font(AppFonts.caption2Bold)
            }
        }
        .foregroundStyle(AppColors.warning)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            AppColors.warningSurface,
            in: RoundedRectangle(cornerRadius: 10)
        )
    }

    private func overlapDescription(_ info: GoalScheduleOverlapInfo) -> String {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let interval = formatter.string(from: info.start, to: info.end)
        let requirement = info.mandatory
            ? L10n.Home.mandatory
            : L10n.GoalCreation.optional
        return "\(info.taskTitle) · \(interval) · \(requirement) · \(L10n.Home.pointsValue(info.points))"
    }
}

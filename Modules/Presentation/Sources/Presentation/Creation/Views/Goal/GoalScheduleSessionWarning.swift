import Common
import Domain
import SwiftUI

struct GoalScheduleSessionWarning: View {
    let session: GoalScheduleReviewSession

    @State private var isPresented = false

    @ViewBuilder
    var body: some View {
        switch session.kind {
        case .noZone(let reason):
            issueButton(
                title: L10n.GoalCreation.noZone,
                body: reason,
                detail: nil
            )
        case .overlap(let reason, let info):
            issueButton(
                title: L10n.GoalCreation.originalConflict,
                body: reason,
                detail: info.map(overlapDescription)
            )
        case .proposed, .manual:
            EmptyView()
        }
    }

    private func issueButton(
        title: String,
        body: String,
        detail: String?
    ) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(title)
                .lineLimit(1)

            Button {
                isPresented = true
            } label: {
                Image(systemName: "info.circle")
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(title)
            .popover(
                isPresented: $isPresented,
                attachmentAnchor: .rect(.bounds),
                arrowEdge: .bottom
            ) {
                GoalScheduleIssuePopover(
                    title: title,
                    message: body,
                    detail: detail
                )
                .presentationCompactAdaptation(.popover)
            }
        }
        .font(AppFonts.caption2Bold)
        .foregroundStyle(AppColors.warning)
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

private struct GoalScheduleIssuePopover: View {
    let title: String
    let message: String
    let detail: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: "exclamationmark.triangle.fill")
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.warning)

            Text(message)
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if let detail {
                Rectangle()
                    .fill(AppColors.divider)
                    .frame(height: 1)

                Text(detail)
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(width: 290, alignment: .leading)
        .background(AppColors.surface)
    }
}

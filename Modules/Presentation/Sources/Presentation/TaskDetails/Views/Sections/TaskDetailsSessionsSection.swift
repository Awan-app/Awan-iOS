import Common
import Domain
import SwiftUI

struct TaskDetailsSessionsSection: View {
    let sessions: [Session]
    let onAdd: () -> Void
    let onEdit: (Session) -> Void
    let onDelete: (UUID) -> Void

    var body: some View {
        TaskDetailsSectionCard(title: L10n.TaskDetails.sessions) {
            if sessions.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    Text(L10n.TaskDetails.noSessions)
                        .font(AppFonts.bodySemibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TaskDetailsAddSessionButton(onAdd: onAdd)
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(sessions) { session in
                        TaskDetailsSessionRow(
                            session: session,
                            onEdit: { onEdit(session) },
                            onDelete: { onDelete(session.id) }
                        )
                    }

                    TaskDetailsAddSessionButton(onAdd: onAdd)
                }
            }
        }
    }
}

private struct TaskDetailsAddSessionButton: View {
    let onAdd: () -> Void

    var body: some View {
        Button(action: onAdd) {
            Label(L10n.GoalCreation.addSession, systemImage: "plus")
                .font(AppFonts.bodySemibold)
                .foregroundStyle(AppColors.accentBlue)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 52)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.accentBlue.opacity(0.3), lineWidth: 1.5)
        )
        .accessibilityLabel(L10n.GoalCreation.addSession)
    }
}

private struct TaskDetailsSessionRow: View {
    let session: Session
    let onEdit: () -> Void
    let onDelete: () -> Void
    @Environment(\.locale) private var locale

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 16),
            surfaceColor: AppColors.sheetBackground,
            borderColor: AppColors.outline.opacity(0.08),
            depthColor: AppColors.outline.opacity(0.08),
            depthOffset: 3,
            contentInsets: EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 10)
        ) {
            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(AppFonts.captionIconBlack)
                    .foregroundStyle(AppColors.accentBlue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(intervalText)
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text("\(statusText) • \(durationText)")
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(statusColor)
                }

                Spacer(minLength: 4)

                Image(systemName: "pencil")
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.textSecondary)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(AppColors.destructive)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.Home.deleteSession)
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onEdit)
            .accessibilityAction(named: L10n.Home.editSessionSchedule, onEdit)
        }
    }

    private var intervalText: String {
        let formatter = DateIntervalFormatter()
        formatter.locale = locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.timeRange.start, to: session.timeRange.end)
    }

    private var durationText: String {
        let minutes = session.timeRange.durationMinutes
        let hours = minutes / 60
        return hours > 0
            ? L10n.TaskDetails.hoursMinutes(hours, minutes % 60)
            : L10n.TaskDetails.minutes(minutes)
    }

    private var statusText: String {
        switch session.status {
        case .planned: L10n.Inbox.sessionsScheduled
        case .completed: L10n.Inbox.filterCompleted
        case .missed: L10n.Inbox.sessionsMissed
        case .cancelled: L10n.Inbox.filterCancelled
        }
    }

    private var statusColor: Color {
        switch session.status {
        case .planned: AppColors.accentBlue
        case .completed: AppColors.accentGreen
        case .missed, .cancelled: AppColors.destructive
        }
    }
}

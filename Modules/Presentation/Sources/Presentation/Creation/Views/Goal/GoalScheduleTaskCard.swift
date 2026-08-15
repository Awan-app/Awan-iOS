import Common
import SwiftUI

struct GoalScheduleTaskCard: View {
    let task: GoalScheduleReviewTask
    let zoneNames: [UUID: String]
    let isFocused: Bool
    let onToggleSuggestion: (UUID) -> Void
    let onEditSession: (GoalScheduleReviewSession) -> Void
    let onAddSession: () -> Void
    let onRemoveSession: (UUID) -> Void

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 20),
            surfaceColor: AppColors.surface,
            borderColor: isFocused ? AppColors.warning : AppColors.divider,
            depthColor: isFocused
                ? AppColors.warning.opacity(0.4)
                : AppColors.divider,
            depthOffset: 5
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text(task.title)
                    .font(AppFonts.headlineBlack)
                    .foregroundStyle(AppColors.textPrimary)

                if task.sessions.isEmpty {
                    GoalScheduleEmptySessionRow(
                        unscheduledReason: task.unscheduledMessage,
                        onAddSession: onAddSession
                    )
                }

                ForEach(task.scheduledSessions) { session in
                    GoalScheduleSessionRow(
                        session: session,
                        zoneName: session.zoneID.flatMap { zoneNames[$0] },
                        onToggleSuggestion: {
                            onToggleSuggestion(session.id)
                        },
                        onEdit: { onEditSession(session) },
                        onRemove: session.isManual
                            ? { onRemoveSession(session.id) }
                            : nil
                    )
                }

                if !task.suggestionSessions.isEmpty {
                    Text(L10n.GoalCreation.suggestions)
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.textSecondary)
                        .textCase(.uppercase)
                        .padding(.top, 2)

                    ForEach(task.suggestionSessions) { session in
                        GoalScheduleSessionRow(
                            session: session,
                            zoneName: session.zoneID.flatMap { zoneNames[$0] },
                            onToggleSuggestion: {
                                onToggleSuggestion(session.id)
                            },
                            onEdit: { onEditSession(session) },
                            onRemove: nil
                        )
                    }
                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}

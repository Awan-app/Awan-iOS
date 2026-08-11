import Common
import Domain
import SwiftUI

struct GoalScheduleReviewView: View {
    let tasks: [GoalScheduleReviewTask]
    let zoneNames: [UUID: String]
    let focusedTaskID: UUID?
    let onFocusHandled: () -> Void
    let onToggleSuggestion: (UUID) -> Void
    let onUpdateSession: (UUID, Date, Date) -> Void
    let onAddManualSession: (UUID, Date, Date) -> Void
    let onRemoveManualSession: (UUID) -> Void
    let onConfirm: () -> Void

    @State private var editor: GoalScheduleEditorContext?

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        header

                        ForEach(tasks) { task in
                            GoalScheduleTaskCard(
                                task: task,
                                zoneNames: zoneNames,
                                isFocused: focusedTaskID == task.id,
                                onToggleSuggestion: onToggleSuggestion,
                                onEditSession: { editor = .edit(session: $0) },
                                onAddSession: {
                                    editor = .add(
                                        taskID: task.taskID,
                                        estimatedDuration: task.estimatedDuration
                                    )
                                },
                                onRemoveSession: onRemoveManualSession
                            )
                            .id(task.id)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
                .onChange(of: focusedTaskID) { _, taskID in
                    guard let taskID else { return }
                    withAnimation(.snappy) {
                        proxy.scrollTo(taskID, anchor: .center)
                    }
                    onFocusHandled()
                }
            }

            AppButton(
                title: L10n.GoalCreation.confirmSchedule,
                icon: "calendar.badge.checkmark",
                color: AppColors.accentGreen,
                onTap: onConfirm
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(AppColors.screenBackground)
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
        .sheet(item: $editor) { context in
            GoalScheduleSessionEditorSheet(
                context: context,
                onSave: { start, end in
                    if let sessionID = context.sessionID {
                        onUpdateSession(sessionID, start, end)
                    } else {
                        onAddManualSession(context.taskID, start, end)
                    }
                    editor = nil
                },
                onDismiss: { editor = nil }
            )
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.GoalCreation.scheduleReviewTitle)
                .font(AppFonts.title2Black)
                .foregroundStyle(AppColors.brandDarkBlue)

            Text(L10n.GoalCreation.scheduleReviewSubtitle)
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

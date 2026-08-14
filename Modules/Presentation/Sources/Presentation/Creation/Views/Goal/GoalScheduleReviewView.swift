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
    let onDismiss: () -> Void
    let onConfirm: () -> Void

    @State private var editor: GoalScheduleEditorContext?
    @State private var showsDismissalConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                AppCloudsHorizon(height: 250)
                    .frame(maxWidth: .infinity)

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 12) {
                            GoalScheduleReviewHeader()

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
                        .padding(.top, 88)
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

                GoalScheduleReviewDismissButton(
                    onDismiss: { showsDismissalConfirmation = true }
                )
                    .padding(.leading, 20)
                    .padding(.top, 16)
            }

            AppButton(
                title: L10n.GoalCreation.confirmAcceptedSessions,
                icon: "calendar.badge.checkmark",
                color: AppColors.accentGreen,
                onTap: onConfirm
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(AppColors.screenBackground)
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
        .background {
            SheetDismissAttemptObserver(
                isDismissalDisabled: true,
                onAttempt: { showsDismissalConfirmation = true }
            )
        }
        .interactiveDismissDisabled()
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
        .alert(
            L10n.GoalCreation.leaveScheduleReviewTitle,
            isPresented: $showsDismissalConfirmation
        ) {
            Button(
                L10n.GoalCreation.continueEditing,
                role: .cancel
            ) {}
            Button(
                L10n.GoalCreation.leaveAsDraft,
                role: .destructive,
                action: onDismiss
            )
        } message: {
            Text(L10n.GoalCreation.leaveScheduleReviewMessage)
        }
    }
}

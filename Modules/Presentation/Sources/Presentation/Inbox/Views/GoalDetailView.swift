//
//  GoalDetailView.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

public struct GoalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let goalID: UUID
    var viewModel: GoalsViewModel
    @State private var scrollPosition = ScrollPosition()
    @State private var isDeleteAlertPresented = false

    public init(goalID: UUID, viewModel: GoalsViewModel) {
        self.goalID = goalID
        self.viewModel = viewModel
    }

    private var goalItem: GoalProgressItem? {
        viewModel.state.allGoals.first { $0.id == goalID }
    }

    private var canScheduleWithAI: Bool {
        guard let item = goalItem else { return false }
        return item.totalCount > 0 && item.breakdown.active == 0 && item.breakdown.completed == 0
    }

    private var addTaskSheetBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.addTaskSheetGoalID == goalID },
            set: { if !$0 { viewModel.send(.dismissAddTaskSheet) } }
        )
    }

    private var addTaskErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.addTaskFailureMessage != nil },
            set: { if !$0 { viewModel.send(.dismissAddTaskError) } }
        )
    }

    private var editGoalSheetBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.editGoalSheetGoalID == goalID },
            set: { if !$0 { viewModel.send(.dismissEditGoalSheet) } }
        )
    }

    private var goalActionErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.goalActionErrorMessage != nil },
            set: { if !$0 { viewModel.send(.dismissGoalActionError) } }
        )
    }

    private var scheduleReviewBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.scheduleReviewGoalID == goalID },
            set: { if !$0 { viewModel.send(.dismissAIScheduleReview) } }
        )
    }

    private var scheduleErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.scheduleErrorMessage != nil },
            set: { if !$0 { viewModel.send(.dismissScheduleErrorMessage) } }
        )
    }

    public var body: some View {
        ZStack {
            AppColors.sheetBackground.ignoresSafeArea()

            if let item = goalItem {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        GoalDetailHeaderCard(goal: item.rawGoal)

                        GoalDetailProgressCard(
                            progressFraction: item.progressFraction,
                            completedCount: item.completedCount,
                            totalCount: item.totalCount,
                            breakdown: item.breakdown
                        )

                        if canScheduleWithAI {
                            GoalDetailAIScheduleCard(
                                isLoading: viewModel.state.isRequestingAISchedule,
                                onSchedule: {
                                    viewModel.send(.requestAISchedule(goalID: goalID))
                                }
                            )
                        }

                        GoalDetailTasksCard(
                            tasks: viewModel.state.orderedGoalTasks,
                            isLoading: viewModel.state.isLoadingGoalTasks,
                            failureMessage: viewModel.state.goalTasksFailureMessage,
                            onRetry: {
                                viewModel.send(.loadGoalTasks(goalID))
                            },
                            onAddTask: {
                                viewModel.send(.showAddTaskSheet(goalID: goalID))
                            },
                            onCompleteTask: { taskID in
                                viewModel.send(.completeTask(taskID))
                            }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
                .scrollPosition($scrollPosition)
            } else if viewModel.state.isLoading {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 12) {
                    Text(L10n.Goals.notFound)
                        .font(AppFonts.subheadlineBold)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(L10n.Goals.detailTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if goalItem != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if canScheduleWithAI {
                            Button {
                                viewModel.send(.requestAISchedule(goalID: goalID))
                            } label: {
                                Label(L10n.Goals.scheduleWithAI, systemImage: "sparkles")
                            }
                        }

                        Button {
                            viewModel.send(.showEditGoalSheet(goalID: goalID))
                        } label: {
                            Label(L10n.Goals.editButton, systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            isDeleteAlertPresented = true
                        } label: {
                            Label(L10n.Goals.deleteButton, systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
            }
        }
        .task {
            if viewModel.state.allGoals.isEmpty {
                viewModel.send(.appeared)
            }
            viewModel.send(.loadGoalTasks(goalID))
        }
        .sheet(isPresented: addTaskSheetBinding) {
            AddInboxTaskSheet(
                goalID: goalID,
                tasks: viewModel.state.inboxTasksForSheet,
                isLoading: viewModel.state.isLoadingInboxTasks,
                onSelectTask: { task in
                    viewModel.send(.addInboxTaskToGoal(task: task, goalID: goalID))
                },
                onDismiss: {
                    viewModel.send(.dismissAddTaskSheet)
                }
            )
        }
        .sheet(isPresented: editGoalSheetBinding) {
            if let item = goalItem {
                EditGoalSheet(
                    goal: item.rawGoal,
                    isSubmitting: viewModel.state.isUpdatingGoal,
                    onUpdate: { title, description, targetDate in
                        viewModel.send(.updateGoal(goalID: goalID, title: title, description: description, targetDate: targetDate))
                    },
                    onDismiss: {
                        viewModel.send(.dismissEditGoalSheet)
                    }
                )
            }
        }
        .fullScreenCover(isPresented: scheduleReviewBinding) {
            ZStack {
                GoalScheduleReviewView(
                    tasks: viewModel.state.scheduleReviewTasks,
                    zoneNames: viewModel.state.scheduleZoneNames,
                    focusedTaskID: viewModel.state.scheduleFocusedTaskID,
                    onFocusHandled: { viewModel.send(.clearFocusedUnscheduledTask) },
                    onToggleSuggestion: { viewModel.send(.toggleScheduleSuggestion(sessionID: $0)) },
                    onUpdateSession: { sessionID, start, end in
                        viewModel.send(.updateScheduleSession(sessionID: sessionID, start: start, end: end))
                    },
                    onAddManualSession: { taskID, start, end in
                        viewModel.send(.addManualScheduleSession(taskID: taskID, start: start, end: end))
                    },
                    onRemoveManualSession: { viewModel.send(.removeManualScheduleSession(sessionID: $0)) },
                    onDismiss: { viewModel.send(.dismissAIScheduleReview) },
                    onConfirm: { viewModel.send(.prepareScheduleConfirmation(goalID: goalID)) }
                )
                .disabled(viewModel.state.showsUnscheduledDialog)

                if viewModel.state.showsUnscheduledDialog {
                    UnscheduledTasksDialog(
                        tasks: viewModel.state.unresolvedScheduleTasks,
                        onAddSessions: { viewModel.send(.focusFirstUnscheduledTask) },
                        onAcceptAllSuggestions: { viewModel.send(.acceptAllSuggestionsAndConfirm(goalID: goalID)) },
                        onContinue: { viewModel.send(.continueWithoutUnscheduledTasks(goalID: goalID)) },
                        onCancel: { viewModel.send(.dismissUnscheduledDialog) }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .zIndex(1)
                }
            }
        }
        .alert(L10n.Goals.deleteConfirmTitle, isPresented: $isDeleteAlertPresented) {
            Button(L10n.Goals.deleteButton, role: .destructive) {
                viewModel.send(.deleteGoal(goalID: goalID))
            }
            Button(L10n.Common.cancel, role: .cancel) {}
        } message: {
            Text(L10n.Goals.deleteConfirmMessage)
        }
        .alert(L10n.Inbox.errorTitle, isPresented: addTaskErrorBinding) {
            Button("OK") { viewModel.send(.dismissAddTaskError) }
        } message: {
            Text(viewModel.state.addTaskFailureMessage ?? "")
        }
        .alert(L10n.Inbox.errorTitle, isPresented: goalActionErrorBinding) {
            Button("OK") { viewModel.send(.dismissGoalActionError) }
        } message: {
            Text(viewModel.state.goalActionErrorMessage ?? "")
        }
        .alert(L10n.Inbox.errorTitle, isPresented: scheduleErrorBinding) {
            Button("OK") { viewModel.send(.dismissScheduleErrorMessage) }
        } message: {
            Text(viewModel.state.scheduleErrorMessage ?? "")
        }
        .onChange(of: viewModel.state.orderedGoalTasks.count) { _, _ in
            scrollPosition.scrollTo(edge: .top)
        }
        .onChange(of: viewModel.state.deletedGoalID) { _, deletedID in
            if deletedID == goalID {
                dismiss()
            }
        }
    }
}

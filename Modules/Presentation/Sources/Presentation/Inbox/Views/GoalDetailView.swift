//
//  GoalDetailView.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

public struct GoalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppCoordinator.self) private var coordinator
    let goalID: UUID
    @State private var viewModel: GoalsViewModel
    @State private var scrollPosition = ScrollPosition()
    @State private var isDeleteAlertPresented = false
    @State private var rewardFlightTaskID: UUID?
    @State private var animatedPoints: Int?
    @State private var pointsPulse = 0
    @State private var pointsAnimationTask: Task<Void, Never>?

    public init(goalID: UUID, viewModel: GoalsViewModel) {
        self.goalID = goalID
        _viewModel = State(initialValue: viewModel)
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
                VStack(spacing: 0) {
                    GoalDetailScreenHeader(
                        rewardPoints: animatedPoints ?? viewModel.state.userPoints,
                        pointsPulse: pointsPulse,
                        canScheduleWithAI: canScheduleWithAI,
                        onBack: { dismiss() },
                        onScheduleWithAI: {
                            viewModel.send(.requestAISchedule(goalID: goalID))
                        },
                        onEdit: {
                            viewModel.send(.showEditGoalSheet(goalID: goalID))
                        },
                        onDelete: {
                            isDeleteAlertPresented = true
                        }
                    )

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
                                },
                                onOpenDetails: { taskID in
                                    coordinator.mainCoordinator.present(
                                        sheet: .taskDetail(taskID)
                                    )
                                }
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                    }
                    .scrollPosition($scrollPosition)
                }
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
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if viewModel.state.allGoals.isEmpty {
                viewModel.send(.appeared)
            }
            viewModel.send(.loadGoalTasks(goalID))
        }
        .onChange(of: coordinator.mainCoordinator.presentedSheet) { previous, current in
            guard case .taskDetail = previous, current == nil else { return }
            viewModel.send(.refresh)
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
        .overlayPreferenceValue(RewardAnchorKey.self) { anchors in
            GeometryReader { proxy in
                if let taskID = rewardFlightTaskID,
                   let animation = viewModel.state.completionRewardAnimation,
                   animation.taskID == taskID {
                    let destinationRect = anchors["goal-points-badge"]
                        .map { proxy[$0] } ?? CGRect(
                            x: proxy.size.width - 50,
                            y: 50,
                            width: 2,
                            height: 2
                        )
                    let sourceRect = anchors[
                        "task-points-\(taskID.uuidString)"
                    ].map { proxy[$0] } ?? CGRect(
                        x: proxy.size.width / 2 - 1,
                        y: proxy.size.height / 2 - 1,
                        width: 2,
                        height: 2
                    )

                    RewardFlightOverlay(
                        sourceRect: sourceRect,
                        destinationRect: destinationRect,
                        points: animation.newPoints - animation.oldPoints,
                        onArrived: {
                            animatePoints(
                                from: animation.oldPoints,
                                to: animation.newPoints
                            )
                        },
                        onFinished: finishRewardFlight
                    )
                    .id(animation.id)
                }
            }
            .allowsHitTesting(false)
        }
        .onChange(of: viewModel.state.completionReward) { _, reward in
            guard viewModel.state.completionRewardAnimation == nil,
                  let transition = reward?.streakTransition else {
                return
            }
            presentStreak(transition)
            viewModel.send(.dismissCompletionReward)
        }
        .onChange(of: viewModel.state.completionRewardAnimation) { _, animation in
            guard let animation else { return }
            pointsAnimationTask?.cancel()
            pointsAnimationTask = nil
            animatedPoints = animation.oldPoints
            rewardFlightTaskID = animation.taskID
        }
        .onDisappear {
            pointsAnimationTask?.cancel()
            pointsAnimationTask = nil
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

    private func animatePoints(from oldValue: Int, to newValue: Int) {
        pointsAnimationTask?.cancel()

        pointsAnimationTask = Task { @MainActor in
            defer {
                if !Task.isCancelled {
                    animatedPoints = nil
                }
            }

            let difference = newValue - oldValue
            guard difference > 0 else {
                if !Task.isCancelled {
                    pointsPulse += 1
                }
                return
            }

            let steps = min(difference, 20)
            for step in 1...steps {
                guard !Task.isCancelled else { return }
                let progress = Double(step) / Double(steps)
                animatedPoints = oldValue + Int(Double(difference) * progress)

                do {
                    try await Task.sleep(for: .milliseconds(15))
                } catch {
                    return
                }
            }

            guard !Task.isCancelled else { return }
            pointsPulse += 1
        }
    }

    private func finishRewardFlight() {
        pointsAnimationTask?.cancel()
        pointsAnimationTask = nil
        animatedPoints = nil
        rewardFlightTaskID = nil

        if let transition = viewModel.state.completionReward?.streakTransition {
            presentStreak(transition)
        }

        viewModel.send(.dismissCompletionReward)
        viewModel.send(.dismissCompletionRewardAnimation)
    }

    private func presentStreak(_ transition: InboxStreakTransition) {
        coordinator.mainCoordinator.presentStreakCelebration(
            previousStreak: transition.oldValue,
            streak: transition.newValue,
            isNewRecord: transition.isNewRecord
        )
    }
}

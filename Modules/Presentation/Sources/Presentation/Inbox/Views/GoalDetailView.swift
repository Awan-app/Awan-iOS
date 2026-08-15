//
//  GoalDetailView.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

public struct GoalDetailView: View {
    let goalID: UUID
    @State private var viewModel: GoalsViewModel
    @State private var scrollPosition = ScrollPosition()

    public init(goalID: UUID, viewModel: GoalsViewModel) {
        self.goalID = goalID
        _viewModel = State(initialValue: viewModel)
    }

    private var goalItem: GoalProgressItem? {
        viewModel.state.allGoals.first { $0.id == goalID }
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

                        GoalDetailTasksCard(
                            tasks: viewModel.state.orderedGoalTasks,
                            isLoading: viewModel.state.isLoadingGoalTasks,
                            failureMessage: viewModel.state.goalTasksFailureMessage,
                            onRetry: {
                                viewModel.send(.loadGoalTasks(goalID))
                            },
                            onAddTask: {
                                viewModel.send(.showAddTaskSheet(goalID: goalID))
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
        .navigationTitle(goalItem?.title ?? L10n.Inbox.tabGoals)
        .navigationBarTitleDisplayMode(.inline)
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
        .alert(L10n.Inbox.errorTitle, isPresented: addTaskErrorBinding) {
            Button("OK") { viewModel.send(.dismissAddTaskError) }
        } message: {
            Text(viewModel.state.addTaskFailureMessage ?? "")
        }
        .onChange(of: viewModel.state.orderedGoalTasks.count) { _, _ in
            scrollPosition.scrollTo(edge: .top)
        }
    }
}

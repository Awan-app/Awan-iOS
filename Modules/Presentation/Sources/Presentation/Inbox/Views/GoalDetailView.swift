//
//  GoalDetailView.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

public struct GoalDetailView: View {
    let goalID: UUID
    @Bindable var viewModel: GoalsViewModel

    public init(goalID: UUID, viewModel: GoalsViewModel) {
        self.goalID = goalID
        self.viewModel = viewModel
    }

    private var goalItem: GoalProgressItem? {
        viewModel.state.allGoals.first { $0.id == goalID }
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
                            }
                        )

                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
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
        .navigationTitle(goalItem?.title ?? L10n.Inbox.tabGoals)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.state.allGoals.isEmpty {
                viewModel.send(.appeared)
            }
            viewModel.send(.loadGoalTasks(goalID))
        }
    }
}

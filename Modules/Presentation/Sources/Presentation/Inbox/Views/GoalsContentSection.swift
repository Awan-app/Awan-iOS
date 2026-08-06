//
//  GoalsContentSection.swift
//  Presentation
//

import Common
import SwiftUI

/// The Goals content rendered inside InboxView's LazyVStack when the Goals tab is selected.
struct GoalsContentSection: View {
    @State private var viewModel: GoalsViewModel

    init(viewModel: GoalsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let state = viewModel.state

        Group {
            if state.isLoading && state.allGoals.isEmpty {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
            } else if let failure = state.failureMessage, state.allGoals.isEmpty {
                goalsFailureView(message: failure)
            } else {
                goalsContent(state)
            }
        }
        .task {
            viewModel.send(.appeared)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private func goalsContent(_ state: GoalsState) -> some View {
        // Subtitle
        Text("Progress from derived task states")
            .font(AppFonts.subheadlineSemibold)
            .foregroundStyle(AppColors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)

        // Search bar — reuse InboxSearchFilterBar
        InboxSearchFilterBar(
            searchQuery: Binding(
                get: { state.searchQuery },
                set: { viewModel.send(.searchQueryChanged($0)) }
            )
        )

        // Section title
        goalsSectionTitle(count: state.filteredGoals.count)

        // List or empty
        if state.filteredGoals.isEmpty {
            goalsEmptyView()
        } else {
            ForEach(state.filteredGoals) { goal in
                GoalCard(goal: goal) {
                    viewModel.send(.selectGoal(goal.id))
                }
            }

            // Footer count
            Text("\(state.filteredGoals.count) \(state.filteredGoals.count == 1 ? "goal" : "goals")")
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
    }

    // MARK: - Section title

    private func goalsSectionTitle(count: Int) -> some View {
        HStack(spacing: 8) {
            Text(L10n.Inbox.tabGoals)
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)

            Text("\(count)")
                .font(AppFonts.captionHeavy)
                .foregroundStyle(AppColors.accentBlue)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(AppColors.accentBlue.opacity(0.12))
                )

            Spacer()
        }
        .padding(.top, 4)
    }

    // MARK: - Empty & Failure

    private func goalsEmptyView() -> some View {
        VStack(spacing: 16) {
            AwanMascotView(state: .goal)
                .frame(width: 140, height: 110)

            Text("No Goals Yet")
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)

            Text("Create your first goal to track progress across your tasks.")
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }

    private func goalsFailureView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(AppFonts.heroSymbol)
                .foregroundStyle(AppColors.warning)

            Text(L10n.Inbox.loadFailed)
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)

            AppButton(
                title: L10n.Home.retry,
                icon: "arrow.clockwise",
                color: AppColors.accentBlue,
                onTap: { viewModel.send(.refresh) }
            )
            .frame(maxWidth: 220)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }
}

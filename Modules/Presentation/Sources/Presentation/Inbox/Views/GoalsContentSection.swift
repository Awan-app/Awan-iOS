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

        VStack(spacing: 0) {
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
        .sheet(isPresented: createGoalSheetBinding) {
            CreateGoalSheet(
                isSubmitting: viewModel.state.isCreatingGoal,
                onCreateGoal: { title, desc, targetDate in
                    viewModel.send(.createGoal(title: title, description: desc, targetDate: targetDate))
                },
                onDismiss: {
                    viewModel.send(.dismissCreateGoalSheet)
                }
            )
        }
    }

    private var createGoalSheetBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.isCreateGoalSheetPresented },
            set: { if !$0 { viewModel.send(.dismissCreateGoalSheet) } }
        )
    }

    // MARK: - Content

    @ViewBuilder
    private func goalsContent(_ state: GoalsState) -> some View {
        // Search bar — reuse InboxSearchFilterBar
        InboxSearchFilterBar(
            searchQuery: Binding(
                get: { state.searchQuery },
                set: { viewModel.send(.searchQueryChanged($0)) }
            ),
            isFilterExpanded: .constant(false),
            hasActiveFilters: false,
            showsFilterButton: false,
            placeholder: L10n.Goals.searchPlaceholder
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
                .padding(.bottom, 14)
            }

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

            Button {
                viewModel.send(.showCreateGoalSheet)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                    Text(L10n.Goals.createButton)
                        .font(AppFonts.captionHeavy)
                }
                .foregroundStyle(AppColors.accentBlue)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(AppColors.accentBlue.opacity(0.12))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Empty & Failure

    private func goalsEmptyView() -> some View {
        VStack(spacing: 16) {
            AwanMascotView(state: .goal)
                .frame(width: 200, height: 150)

            Text(L10n.Goals.emptyTitle)
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)

            Text(L10n.Goals.emptySubtitle)
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

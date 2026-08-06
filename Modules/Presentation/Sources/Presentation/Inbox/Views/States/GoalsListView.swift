//
//  GoalsListView.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct GoalsListView: View {
    let goals: [Goal]
    let isLoading: Bool
    let failureMessage: String?
    let onRefresh: () -> Void
    let onGoalSelected: (Goal) -> Void

    @State private var searchQuery: String = ""
    @State private var sortOption: GoalSortOption = .newest

    private var filteredAndSortedGoals: [Goal] {
        var result = goals

        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter { goal in
                goal.name.localizedCaseInsensitiveContains(query) ||
                (goal.description?.localizedCaseInsensitiveContains(query) ?? false)
            }
        }

        switch sortOption {
        case .newest:
            result.sort { $0.createdAt > $1.createdAt }
        case .oldest:
            result.sort { $0.createdAt < $1.createdAt }
        case .nameAZ:
            result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameZA:
            result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        case .deadline:
            result.sort { ($0.deadline ?? .distantFuture) < ($1.deadline ?? .distantFuture) }
        }

        return result
    }

    var body: some View {
        VStack(spacing: 18) {
            GoalSearchSortBar(
                searchQuery: $searchQuery,
                selectedSort: $sortOption
            )

            if let failure = failureMessage, goals.isEmpty {
                failureView(message: failure)
            } else if isLoading && goals.isEmpty {
                loadingView
            } else {
                sectionTitleRow(count: filteredAndSortedGoals.count)

                if filteredAndSortedGoals.isEmpty {
                    emptyView
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredAndSortedGoals) { goal in
                            GoalCard(
                                goal: goal,
                                progress: 0.0,
                                onTap: { onGoalSelected(goal) }
                            )
                        }
                    }
                }
            }
        }
    }

    private func sectionTitleRow(count: Int) -> some View {
        HStack(spacing: 8) {
            Text(L10n.Goals.sectionTitle)
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

    private var emptyView: some View {
        VStack(spacing: 16) {
            AwanMascotView(state: .goal)
                .frame(width: 160, height: 120)

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

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .padding(22)
                .background(
                    AppMaterials.loadingOverlay,
                    in: RoundedRectangle(cornerRadius: 20)
                )
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    private func failureView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(AppFonts.heroSymbol)
                .foregroundStyle(AppColors.warning)

            Text(L10n.Goals.loadFailed)
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)

            AppButton(
                title: L10n.Home.retry,
                icon: "arrow.clockwise",
                color: AppColors.accentBlue,
                onTap: onRefresh
            )
            .frame(maxWidth: 220)
        }
        .padding(24)
    }
}

// MARK: - SwiftUI Previews

#Preview("Goals List - Populated") {
    ScrollView {
        GoalsListView(
            goals: [
                Goal(id: UUID(), name: "Build iOS App", description: "Complete Presentation & Domain modules.", status: .active, deadline: Date().addingTimeInterval(86400 * 5)),
                Goal(id: UUID(), name: "Learn SwiftUI", description: "Master layout & observation framework.", status: .active, deadline: nil),
                Goal(id: UUID(), name: "Design System Refactor", description: "Apply AppDepthSurface across all components.", status: .active, deadline: Date().addingTimeInterval(86400 * 14))
            ],
            isLoading: false,
            failureMessage: nil,
            onRefresh: {},
            onGoalSelected: { _ in }
        )
        .padding()
    }
    .background(AppColors.screenBackground)
}

#Preview("Goals List - Empty") {
    ScrollView {
        GoalsListView(
            goals: [],
            isLoading: false,
            failureMessage: nil,
            onRefresh: {},
            onGoalSelected: { _ in }
        )
        .padding()
    }
    .background(AppColors.screenBackground)
}

#Preview("Goals List - Loading") {
    ScrollView {
        GoalsListView(
            goals: [],
            isLoading: true,
            failureMessage: nil,
            onRefresh: {},
            onGoalSelected: { _ in }
        )
        .padding()
    }
    .background(AppColors.screenBackground)
}

#Preview("Goals List - Failure") {
    ScrollView {
        GoalsListView(
            goals: [],
            isLoading: false,
            failureMessage: "Network connection lost.",
            onRefresh: {},
            onGoalSelected: { _ in }
        )
        .padding()
    }
    .background(AppColors.screenBackground)
}

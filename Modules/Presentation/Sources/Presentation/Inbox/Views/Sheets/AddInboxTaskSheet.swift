//
//  AddInboxTaskSheet.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct AddInboxTaskSheet: View {
    let goalID: UUID
    let tasks: [AwanTask]
    let isLoading: Bool
    let onSelectTask: (AwanTask) -> Void
    let onDismiss: () -> Void

    @State private var searchQuery: String = ""

    private var filteredTasks: [AwanTask] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return tasks }
        return tasks.filter { task in
            task.title.localizedCaseInsensitiveContains(query) ||
            (task.description?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }

    var body: some View {
        AppSheet(
            sizing: .detents([.medium, .large]),
            backgroundColor: AppColors.screenBackground
        ) {
            NavigationStack {
                VStack(spacing: 0) {
                    if isLoading && tasks.isEmpty {
                        VStack(spacing: 16) {
                            ProgressView().controlSize(.large)
                            Text(L10n.Inbox.addToGoalLoading)
                                .font(AppFonts.subheadlineSemibold)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if tasks.isEmpty {
                        emptyView
                    } else {
                        VStack(spacing: 12) {
                            InboxSearchFilterBar(
                                searchQuery: $searchQuery,
                                isFilterExpanded: .constant(false),
                                hasActiveFilters: false,
                                showsFilterButton: false,
                                placeholder: L10n.Goals.searchPlaceholder
                            )
                            .padding(.horizontal, 16)
                            .padding(.top, 12)

                            if filteredTasks.isEmpty {
                                noSearchResultsView
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: 12) {
                                        ForEach(filteredTasks) { task in
                                            taskRow(task)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 16)
                                }
                            }
                        }
                    }
                }
                .background(alignment: .top) {
                    AppCloudsHorizon(height: 220)
                        .frame(maxWidth: .infinity)
                }
                .background(AppColors.screenBackground.ignoresSafeArea())
                .navigationTitle(L10n.Inbox.addToGoalSheetTitle)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private func taskRow(_ task: AwanTask) -> some View {
        Button {
            onSelectTask(task)
        } label: {
            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 20),
                surfaceColor: AppColors.surface,
                borderColor: AppColors.outline.opacity(0.10),
                depthColor: AppColors.outline.opacity(0.08),
                borderWidth: 1.5,
                depthOffset: 4,
                contentInsets: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            ) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppColors.accentBlue.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: "text.badge.plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AppColors.accentBlue)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(AppFonts.headlineBlack)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        if let desc = task.description, !desc.isEmpty {
                            Text(desc)
                                .font(AppFonts.subheadlineSemibold)
                                .foregroundStyle(AppColors.textSecondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 10, weight: .bold))
                            Text(L10n.Home.minutesShort(task.duration.minutes))
                                .font(AppFonts.caption2Bold)
                        }
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.top, 2)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.textSecondary.opacity(0.4))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            AwanMascotView(state: .goal)
                .frame(width: 140, height: 110)

            Text(L10n.Goals.noTasksAssigned)
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)

            Text(L10n.Inbox.addToGoalEmptyInbox)
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var noSearchResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                .padding(.top, 40)

            Text(L10n.Inbox.noMatchesFound)
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)

            Text(L10n.Inbox.tryAdjustingQuery)
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

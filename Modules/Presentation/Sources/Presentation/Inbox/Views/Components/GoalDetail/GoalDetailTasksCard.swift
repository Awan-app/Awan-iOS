//
//  GoalDetailTasksCard.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

/// Renders the ordered goal task list.
/// All dependency ordering is done in `GoalsViewModel`; this view is purely presentational.
struct GoalDetailTasksCard: View {
    let tasks: [GoalDetailTaskItem]
    let isLoading: Bool
    let failureMessage: String?
    let onRetry: () -> Void
    var onAddTask: (() -> Void)? = nil

    private var independentCount: Int { tasks.filter { !$0.isDependent }.count }
    private var dependentCount: Int   { tasks.filter {  $0.isDependent }.count }

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 24),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.outline.opacity(0.06),
            depthColor: AppColors.outline.opacity(0.10),
            borderWidth: 1.5,
            depthOffset: 4
        ) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.Goals.tasks)
                            .font(AppFonts.title3Black)
                            .foregroundStyle(AppColors.textPrimary)

                        if !tasks.isEmpty {
                            Text(taskSubtitle)
                                .font(AppFonts.caption2Bold)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    if !tasks.isEmpty {
                        countBadge
                    }
                }

                // ── List states ─────────────────────────────────────────
                if isLoading && tasks.isEmpty {
                    loadingView
                } else if let failure = failureMessage, tasks.isEmpty {
                    failureView(failure)
                } else if tasks.isEmpty {
                    emptyView
                    if let onAddTask, !isLoading {
                        addTaskButton(onAddTask)
                    }
                } else {
                    taskRoadmap
                }
            }
        }
    }

    // MARK: - Sub-views

    private var taskRoadmap: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(tasks.enumerated()), id: \.element.id) { listIndex, item in
                GoalDetailTaskRow(
                    item: item,
                    isLast: (listIndex == tasks.count - 1) && (onAddTask == nil)
                )
            }

            if let onAddTask, !isLoading {
                addTaskButton(onAddTask)
            }
        }
        .padding(.top, 2)
    }

    private var countBadge: some View {
        Text("\(tasks.count)")
            .font(AppFonts.captionHeavy)
            .foregroundStyle(AppColors.accentBlue)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Capsule().fill(AppColors.accentBlue.opacity(0.12)))
            .overlay(Capsule().stroke(AppColors.accentBlue.opacity(0.25), lineWidth: 1))
    }

    private var taskSubtitle: String {
        if dependentCount > 0 {
            return L10n.Goals.taskDependencySummary(independentCount, dependentCount)
        }
        return L10n.Goals.tasksCount(tasks.count)
    }

    private var loadingView: some View {
        HStack(spacing: 10) {
            ProgressView().controlSize(.small)
            Text(L10n.Goals.loadingTasks)
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func failureView(_ message: String) -> some View {
        VStack(spacing: 8) {
            Text(message)
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.destructive)
                .multilineTextAlignment(.center)

            Button(L10n.Home.retry) { onRetry() }
                .font(AppFonts.subheadlineBold)
                .foregroundStyle(AppColors.accentBlue)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var emptyView: some View {
        Text(L10n.Goals.noTasksAssigned)
            .font(AppFonts.subheadlineSemibold)
            .foregroundStyle(AppColors.textSecondary)
            .padding(.vertical, 8)
    }

    private func addTaskButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppColors.accentBlue.opacity(0.14))
                        .frame(width: 28, height: 28)
                        .overlay {
                            Circle()
                                .stroke(AppColors.accentBlue.opacity(0.45), lineWidth: 1.5)
                        }

                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(AppColors.accentBlue)
                }
                .frame(width: 32, height: 28)

                Text(L10n.Home.addTask)
                    .font(AppFonts.subheadlineBold)
                    .foregroundStyle(AppColors.accentBlue)

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

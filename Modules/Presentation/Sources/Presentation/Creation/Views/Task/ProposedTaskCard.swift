//
//  ProposedTaskCard.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct ProposedTaskCard: View {
    let task: ProposedTask
    let categories: [TaskCategory]
    let zones: [Zone]
    let categoryErrorMessage: String?
    let categoryPopoverArrowEdge: Edge
    let onRetryCategories: () -> Void
    let isSelected: Bool
    let onToggleSelect: () -> Void
    let onDurationChanged: (Int) -> Void
    let onCategoryChanged: (UUID?) -> Void
    let onEditSession: (ProposedSessionSource, ProposedSession) -> Void
    let onAddSession: () -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {

                ProposedTaskCardHeader(
                    title: task.draft.task.title,
                    description: task.draft.task.description,
                    isSelected: isSelected,
                    onToggleSelect: onToggleSelect
                )

                Divider()

                HStack(spacing: 8) {
                    ProposedTaskCategoryButton(
                        categories: categories,
                        zones: zones,
                        selectedCategoryID: task.draft.task.categoryId,
                        errorMessage: categoryErrorMessage,
                        popoverArrowEdge: categoryPopoverArrowEdge,
                        onRetry: onRetryCategories,
                        onCategoryChanged: onCategoryChanged
                    )

                    Spacer()

                    Label("\(task.draft.task.estimatedPoints) pts", systemImage: "star.fill")
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.reward)
                        .environment(\.layoutDirection, .leftToRight)
                }

                HStack {
                    Text(L10n.Home.duration)
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.textSecondary)

                    Spacer()

                    HStack(spacing: 10) {
                        Button {
                            if task.draft.task.estimatedDuration > 15 {
                                onDurationChanged(task.draft.task.estimatedDuration - 15)
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(
                                    task.draft.task.estimatedDuration > 15
                                        ? AppColors.accentBlue
                                        : AppColors.textSecondary.opacity(0.3)
                                )
                        }
                        .disabled(task.draft.task.estimatedDuration <= 15)

                        Text(L10n.Home.minutesShort(task.draft.task.estimatedDuration))
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(minWidth: 55)

                        Button {
                            if task.draft.task.estimatedDuration < 480 {
                                onDurationChanged(task.draft.task.estimatedDuration + 15)
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(
                                    task.draft.task.estimatedDuration < 480
                                        ? AppColors.accentBlue
                                        : AppColors.textSecondary.opacity(0.3)
                                )
                        }
                        .disabled(task.draft.task.estimatedDuration >= 480)
                    }
                }

                let hasSessions = !task.draft.sessions.isEmpty || !task.aiProposedSessions.isEmpty
                if hasSessions {
                    ProposedTaskSessionsRow(
                        fixedSessions: task.draft.sessions,
                        aiSessions: task.aiProposedSessions,
                        onEditSession: onEditSession
                    )
                } else {
                    AppButton(
                        title: L10n.Home.setSchedule,
                        icon: "calendar.badge.plus",
                        color: AppColors.accentBlue,
                        size: .compact,
                        onTap: onAddSession
                    )
                }

                if !task.reason.isEmpty {
                    ProposedTaskReasonChip(reason: task.reason)
                }
            }
        }
        .opacity(isSelected ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

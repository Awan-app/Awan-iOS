//
//  AddToGoalSheet.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct AddToGoalSheet: View {
    let task: InboxTaskItem
    let goals: [Goal]
    let isLoading: Bool
    let onSelectGoal: (Goal) -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Task header preview card
                taskHeaderView

                Divider()
                    .background(AppColors.divider)
                    .padding(.vertical, 12)

                // List content
                if isLoading && goals.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                            .controlSize(.large)
                        Text(L10n.Inbox.addToGoalLoading)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if goals.isEmpty {
                    emptyGoalsView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(goals) { goal in
                                GoalPickerRow(goal: goal) {
                                    onSelectGoal(goal)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .background(AppColors.screenBackground.ignoresSafeArea())
            .navigationTitle(L10n.Inbox.addToGoalSheetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(28)
    }

    private var taskHeaderView: some View {
        HStack(spacing: 12) {
            Image(systemName: "text.badge.plus")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppColors.accentBlue)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(AppFonts.headlineBlack)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                if let desc = task.description, !desc.isEmpty {
                    Text(desc)
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var emptyGoalsView: some View {
        VStack(spacing: 16) {
            AwanMascotView(state: .goal)
                .frame(width: 140, height: 110)

            Text(L10n.Inbox.noGoalsAvailable)
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)

            Text(L10n.Inbox.noGoalsAvailableHint)
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

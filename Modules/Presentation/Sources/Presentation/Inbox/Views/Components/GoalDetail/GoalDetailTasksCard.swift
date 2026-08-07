//
//  GoalDetailTasksCard.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct GoalDetailTasksCard: View {
    let tasks: [AwanTask]
    let isLoading: Bool
    let failureMessage: String?
    let completedCount: Int
    let onRetry: () -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Tasks")
                        .font(AppFonts.title3Black)
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    if !tasks.isEmpty {
                        Text("\(completedCount)/\(tasks.count)")
                            .font(AppFonts.captionHeavy)
                            .foregroundStyle(AppColors.accentBlue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(AppColors.accentBlue.opacity(0.12))
                            )
                    }
                }

                if isLoading && tasks.isEmpty {
                    HStack(spacing: 10) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Loading tasks...")
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .center)
                } else if let failure = failureMessage, tasks.isEmpty {
                    VStack(spacing: 8) {
                        Text(failure)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.destructive)
                            .multilineTextAlignment(.center)

                        Button("Retry") {
                            onRetry()
                        }
                        .font(AppFonts.subheadlineBold)
                        .foregroundStyle(AppColors.accentBlue)
                    }
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .center)
                } else if tasks.isEmpty {
                    Text("No tasks assigned to this goal.")
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.vertical, 8)
                } else {
                    VStack(spacing: 10) {
                        ForEach(tasks) { task in
                            GoalDetailTaskRow(task: task)
                        }
                    }
                }
            }
        }
    }
}

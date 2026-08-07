//
//  GoalDetailTaskRow.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct GoalDetailTaskRow: View {
    let task: AwanTask

    private var isCompleted: Bool {
        task.status == .completed
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(isCompleted ? AppColors.accentGreen : AppColors.accentBlue)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(AppFonts.subheadlineBold)
                    .foregroundStyle(isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                    .strikethrough(isCompleted, color: AppColors.textSecondary)

                if let desc = task.description, !desc.isEmpty {
                    Text(desc)
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if isCompleted {
                Text("Done")
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.accentGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(AppColors.accentGreen.opacity(0.12))
                    )
            } else if task.status == .inProgress {
                Text("In Progress")
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.warning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(AppColors.warning.opacity(0.12))
                    )
            }
        }
        .padding(.vertical, 4)
    }
}

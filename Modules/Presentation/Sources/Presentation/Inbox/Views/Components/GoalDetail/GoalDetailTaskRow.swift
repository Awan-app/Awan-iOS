//
//  GoalDetailTaskRow.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct GoalDetailTaskRow: View {
    let index: Int
    let task: AwanTask
    var allTasks: [AwanTask] = []

    private var parentTaskNames: [String] {
        guard !task.dependencyIDs.isEmpty else { return [] }
        let tasksByID = Dictionary(grouping: allTasks, by: \.id)
        return task.dependencyIDs.compactMap { tasksByID[$0]?.first?.title }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(index).")
                .font(AppFonts.subheadlineBold)
                .foregroundStyle(AppColors.textSecondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(AppFonts.subheadlineBold)
                    .foregroundStyle(AppColors.textPrimary)

                if let desc = task.description, !desc.isEmpty {
                    Text(desc)
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }

                // Dependency Relationship Visualization
                if !task.dependencyIDs.isEmpty {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.turn.down.right")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(AppColors.accentBlue)

                        if !parentTaskNames.isEmpty {
                            Text(L10n.Goals.dependsOnNames(parentTaskNames.joined(separator: ", ")))
                                .font(AppFonts.caption2Bold)
                                .foregroundStyle(AppColors.accentBlue)
                        } else {
                            Text(L10n.Goals.dependsOnCount(task.dependencyIDs.count))
                                .font(AppFonts.caption2Bold)
                                .foregroundStyle(AppColors.accentBlue)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(AppColors.accentBlue.opacity(0.10))
                    )
                }
            }

            Spacer(minLength: 4)

            // Category & Duration Chip
            VStack(alignment: .trailing, spacing: 4) {
                if let category = task.category {
                    Text(category.name)
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(AppColors.outline.opacity(0.12))
                        )
                }

                Text(L10n.Home.minutesShort(task.duration.minutes))
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppColors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppColors.outline.opacity(0.10), lineWidth: 1)
        )
    }
}

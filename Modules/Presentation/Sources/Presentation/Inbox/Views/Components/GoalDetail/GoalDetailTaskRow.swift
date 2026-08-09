//
//  GoalDetailTaskRow.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

/// Renders a single task row inside the Goal Detail task roadmap.
/// All sorting and dependency logic is resolved in `GoalsViewModel`;
/// this view only reads pre-computed properties from `GoalDetailTaskItem`.
struct GoalDetailTaskRow: View {
    let item: GoalDetailTaskItem
    let isLast: Bool

    // MARK: - Body

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            timelineColumn
            VStack(alignment: .leading, spacing: 0) {
                contentRow
                    .padding(.bottom, isLast ? 0 : 12)
            }
        }
    }

    // MARK: - Timeline

    private var timelineColumn: some View {
        VStack(spacing: 0) {
            stepCircle
            if !isLast { connector }
        }
    }

    private var stepCircle: some View {
        ZStack(alignment: .topTrailing) {
            // Numbered circle — blue for root tasks, muted for dependent tasks
            ZStack {
                Circle()
                    .fill(
                        item.isDependent
                            ? AppColors.surface
                            : AppColors.accentBlue.opacity(0.14)
                    )
                    .frame(width: 28, height: 28)
                    .overlay {
                        Circle()
                            .stroke(
                                item.isDependent
                                    ? AppColors.outline.opacity(0.25)
                                    : AppColors.accentBlue.opacity(0.45),
                                lineWidth: 1.5
                            )
                    }

                Text("\(item.displayIndex)")
                    .font(.system(.caption2, design: .rounded, weight: .black))
                    .foregroundStyle(
                        item.isDependent ? AppColors.textSecondary : AppColors.accentBlue
                    )
            }

            // Small link badge for dependent tasks
            if item.isDependent {
                Image(systemName: "link")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(AppColors.accentBlue)
                    .padding(2.5)
                    .background(Circle().fill(AppColors.accentBlue.opacity(0.15)))
                    .overlay(Circle().stroke(AppColors.accentBlue.opacity(0.30), lineWidth: 1))
                    .offset(x: 4, y: -4)
            }
        }
        .frame(width: 32)
    }

    private var connector: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [AppColors.outline.opacity(0.25), AppColors.outline.opacity(0.10)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 1.5)
            .frame(maxHeight: .infinity)
            .padding(.horizontal, (32 - 1.5) / 2)
    }

    // MARK: - Content

    private var contentRow: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                Text(item.task.title)
                    .font(AppFonts.subheadlineBold)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if let desc = item.task.description, !desc.isEmpty {
                    Text(desc)
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }

                // Dependency indicator — compact, icon-driven
                if item.isDependent {
                    dependencyIndicator
                        .padding(.top, 2)
                }
            }

            Spacer(minLength: 6)

            // Trailing: duration + optional category
            VStack(alignment: .trailing, spacing: 4) {
                durationChip

                if let category = item.task.category {
                    categoryChip(category)
                }
            }
        }
    }

   

    @ViewBuilder
    private var dependencyIndicator: some View {
        if !item.dependencyNames.isEmpty {
            HStack(spacing: 4) {
                Image(systemName: "link")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(AppColors.accentBlue.opacity(0.75))

                Text(L10n.Goals.dependsOnNames(item.dependencyNames.joined(separator: ", ")))
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.accentBlue.opacity(0.80))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(AppColors.accentBlue.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(AppColors.accentBlue.opacity(0.18), lineWidth: 1)
            )
        }
    }

    // MARK: - Category chip
    

    private func categoryChip(_ category: TaskCategory) -> some View {
        HStack(spacing: 3) {
            Image(systemName: "tag")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(AppColors.textSecondary)

            Text(category.name)
                .font(AppFonts.caption2Bold)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(AppColors.outline.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(AppColors.outline.opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: - Duration chip

    private var durationChip: some View {
        HStack(spacing: 3) {
            Image(systemName: "clock")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(AppColors.textSecondary)

            Text(L10n.Home.minutesShort(item.task.duration.minutes))
                .font(AppFonts.caption2Bold)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(AppColors.outline.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(AppColors.outline.opacity(0.18), lineWidth: 1)
        )
    }
}

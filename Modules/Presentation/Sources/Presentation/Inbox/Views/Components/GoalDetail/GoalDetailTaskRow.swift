import Common
import Domain
import SwiftUI

/// Renders a single task row inside the Goal Detail task roadmap.
struct GoalDetailTaskRow: View {
    let item: GoalDetailTaskItem
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            timelineColumn
            VStack(alignment: .leading, spacing: 0) {
                contentRow
                    .padding(.bottom, isLast ? 0 : 20)
            }
        }
    }

    private var timelineColumn: some View {
        VStack(spacing: 0) {
            stepCircle
            if !isLast { connector }
        }
    }

    private var stepCircle: some View {
        ZStack(alignment: .topTrailing) {
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
                        item.isDependent
                            ? AppColors.textSecondary
                            : AppColors.accentBlue
                    )
            }

            if item.isDependent {
                Image(systemName: "link")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(AppColors.accentBlue)
                    .padding(2.5)
                    .background(Circle().fill(AppColors.accentBlue.opacity(0.15)))
                    .overlay {
                        Circle().stroke(
                            AppColors.accentBlue.opacity(0.30),
                            lineWidth: 1
                        )
                    }
                    .offset(x: 4, y: -4)
            }
        }
        .frame(width: 32)
    }

    private var connector: some View {
        Rectangle()
            .fill(AppColors.outline.opacity(0.18))
            .frame(width: 1.5)
            .frame(maxHeight: .infinity)
            .padding(.horizontal, (32 - 1.5) / 2)
    }

    private var contentRow: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                Text(item.task.title)
                    .font(AppFonts.subheadlineBold)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if let description = item.task.description, !description.isEmpty {
                    Text(description)
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }

                if item.isDependent {
                    dependencyIndicator
                        .padding(.top, 2)
                }
            }

            Spacer(minLength: 6)

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
        if !item.dependencyIndices.isEmpty {
            HStack(spacing: 6) {
                Image(systemName: "link")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(AppColors.accentBlue.opacity(0.75))

                Text(L10n.Goals.dependsOn)
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.accentBlue.opacity(0.80))

                ForEach(Array(item.dependencyIndices.prefix(2)), id: \.self) { index in
                    Text("\(index)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(AppColors.accentBlue)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(AppColors.accentBlue.opacity(0.12)))
                        .overlay {
                            Circle().stroke(
                                AppColors.accentBlue.opacity(0.32),
                                lineWidth: 1
                            )
                        }
                }

                if remainingDependencyCount > 0 {
                    Text(L10n.Goals.moreDependencies(remainingDependencyCount))
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(AppColors.accentBlue)
                        .lineLimit(1)
                        .padding(.horizontal, 6)
                        .frame(height: 20)
                        .background(
                            Capsule().fill(AppColors.accentBlue.opacity(0.12))
                        )
                        .overlay {
                            Capsule().stroke(
                                AppColors.accentBlue.opacity(0.32),
                                lineWidth: 1
                            )
                        }
                }
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(AppColors.accentBlue.opacity(0.08))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(AppColors.accentBlue.opacity(0.18), lineWidth: 1)
            }
        }
    }

    private var remainingDependencyCount: Int {
        max(0, item.dependencyIndices.count - 2)
    }

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
        .overlay {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(AppColors.outline.opacity(0.18), lineWidth: 1)
        }
    }

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
        .overlay {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(AppColors.outline.opacity(0.18), lineWidth: 1)
        }
    }
}

import Common
import Domain
import SwiftUI

/// Renders a single task row inside the Goal Detail task roadmap.
struct GoalDetailTaskRow: View {
    let item: GoalDetailTaskItem
    let isLast: Bool
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    var onCompleteTask: (() -> Void)? = nil
    var onOpenDetails: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            topNodeHeader

            VStack(alignment: .leading, spacing: 6) {
                InboxTaskCard(
                    taskItem: item.asInboxTaskItem,
                    isExpanded: isExpanded,
                    onToggleExpand: onToggleExpand,
                    onCompleteTask: onCompleteTask,
                    onOpenDetails: onOpenDetails
                )

                if item.isDependent && !item.dependencyIndices.isEmpty {
                    dependencyIndicator
                        .padding(.leading, 4)
                }
            }
            .frame(maxWidth: .infinity)

            if !isLast {
                bottomConnector
            }
        }
    }

    private var topNodeHeader: some View {
        VStack(spacing: 0) {
            stepCircle

            Rectangle()
                .fill(AppColors.outline.opacity(0.18))
                .frame(width: 1.5, height: 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 12)
    }

    private var bottomConnector: some View {
        Rectangle()
            .fill(AppColors.outline.opacity(0.18))
            .frame(width: 1.5, height: 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 27.25)
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

    @ViewBuilder
    private var dependencyIndicator: some View {
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
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(AppColors.accentBlue.opacity(0.08))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(AppColors.accentBlue.opacity(0.18), lineWidth: 1)
        }
    }

    private var remainingDependencyCount: Int {
        max(0, item.dependencyIndices.count - 2)
    }
}

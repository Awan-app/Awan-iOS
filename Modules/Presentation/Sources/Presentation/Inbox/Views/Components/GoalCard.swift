//
//  GoalCard.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct GoalCard: View {
    let goal: GoalProgressItem
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 24),
                surfaceColor: AppColors.surface,
                borderColor: borderColor,
                depthColor: AppColors.outline.opacity(0.10),
                borderWidth: 1.5,
                depthOffset: 4,
                contentInsets: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            ) {
                VStack(alignment: .leading, spacing: 14) {
                    // Header row
                    HStack(alignment: .top, spacing: 12) {
                        goalIcon

                        VStack(alignment: .leading, spacing: 3) {
                            Text(goal.title)
                                .font(AppFonts.headlineBlack)
                                .foregroundStyle(AppColors.textPrimary)
                                .multilineTextAlignment(.leading)

                            if let desc = goal.description, !desc.isEmpty {
                                Text(desc)
                                    .font(AppFonts.subheadlineSemibold)
                                    .foregroundStyle(AppColors.textSecondary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                            }
                        }

                        Spacer(minLength: 4)

                        VStack(alignment: .trailing, spacing: 4) {
                            if let deadline = goal.deadlineText {
                                deadlineBadge(deadline)
                            }
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AppColors.textSecondary.opacity(0.5))
                        }
                    }

                    Divider().background(AppColors.divider)

                    // Progress section
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text("\(Int(goal.progressFraction * 100))%")
                                .font(AppFonts.title2Black)
                                .foregroundStyle(progressColor)

                            Text("\(goal.completedCount) of \(goal.totalCount) tasks completed")
                                .font(AppFonts.subheadlineSemibold)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppColors.outline.opacity(0.15))
                                    .frame(height: 8)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [progressColor, progressColor.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: max(0, geo.size.width * goal.progressFraction),
                                        height: 8
                                    )
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: goal.progressFraction)
                            }
                        }
                        .frame(height: 8)
                    }

                    // Breakdown chips
                    if goal.totalCount > 0 {
                        breakdownRow
                    }

                    // Footer note
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                        Text("Calculated from sessions")
                            .font(AppFonts.caption2Bold)
                            .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                        Spacer()
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sub-views

    private var goalIcon: some View {
        Circle()
            .fill(progressColor.opacity(0.15))
            .overlay(
                Image(systemName: "target")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(progressColor)
            )
            .frame(width: 44, height: 44)
    }

    private func deadlineBadge(_ text: String) -> some View {
        Text("Target \(text)")
            .font(AppFonts.caption2Bold)
            .foregroundStyle(AppColors.accentBlue)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppColors.accentBlue.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppColors.accentBlue.opacity(0.35), lineWidth: 1.5)
            )
    }

    @ViewBuilder
    private var breakdownRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if goal.breakdown.completed > 0 {
                    breakdownChip(
                        count: goal.breakdown.completed,
                        label: "Completed",
                        icon: "checkmark.circle",
                        color: AppColors.accentGreen
                    )
                }
                if goal.breakdown.active > 0 {
                    breakdownChip(
                        count: goal.breakdown.active,
                        label: "Active",
                        icon: "circle.dotted",
                        color: AppColors.warning
                    )
                }
                if goal.breakdown.drafted > 0 {
                    breakdownChip(
                        count: goal.breakdown.drafted,
                        label: "Drafted",
                        icon: "circle.dashed",
                        color: AppColors.textSecondary
                    )
                }
                if goal.breakdown.cancelled > 0 {
                    breakdownChip(
                        count: goal.breakdown.cancelled,
                        label: "Cancelled",
                        icon: "xmark.circle",
                        color: AppColors.destructive
                    )
                }
            }
        }
    }

    private func breakdownChip(count: Int, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(color)
            Text("\(count) \(label)")
                .font(AppFonts.caption2Bold)
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private var progressColor: Color {
        if goal.progressFraction >= 1.0 { return AppColors.accentGreen }
        if goal.progressFraction >= 0.5 { return AppColors.accentBlue }
        return AppColors.warning
    }

    private var borderColor: Color {
        if goal.progressFraction >= 1.0 { return AppColors.accentGreen.opacity(0.35) }
        return AppColors.outline.opacity(0.12)
    }
}

// MARK: - Previews

#Preview("Goal Card — Active") {
    GoalCard(
        goal: GoalProgressItem(
            id: UUID(),
            title: "Learn Spring Boot",
            description: "Master Spring Boot and build a REST API",
            deadlineText: "Dec 31",
            progressFraction: 0.5,
            completedCount: 2,
            totalCount: 4,
            breakdown: GoalTaskBreakdown(drafted: 1, active: 1, completed: 2, cancelled: 0),
            rawGoal: Goal(id: UUID(), name: "Learn Spring Boot", deadline: nil)
        )
    )
    .padding()
    .background(AppColors.screenBackground)
}

#Preview("Goal Card — Completed") {
    GoalCard(
        goal: GoalProgressItem(
            id: UUID(),
            title: "Launch graduation project",
            description: "Build and ship the first Awan release",
            deadlineText: "Aug 30",
            progressFraction: 0.6,
            completedCount: 3,
            totalCount: 5,
            breakdown: GoalTaskBreakdown(drafted: 0, active: 1, completed: 3, cancelled: 1),
            rawGoal: Goal(id: UUID(), name: "Launch graduation project", deadline: nil)
        )
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}

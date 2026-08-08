//
//  GoalDetailProgressCard.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct GoalDetailProgressCard: View {
    let progressFraction: Double
    let completedCount: Int
    let totalCount: Int
    let breakdown: GoalTaskBreakdown?

    private var progressColor: Color {
        if progressFraction >= 1.0 {
            return AppColors.accentGreen
        } else if progressFraction > 0.0 {
            return AppColors.accentBlue
        } else {
            return AppColors.warning
        }
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.Goals.progress)
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundStyle(AppColors.textSecondary)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(Int(progressFraction * 100))%")
                            .font(AppFonts.title2Black)
                            .foregroundStyle(progressColor)

                        Text(L10n.Goals.tasksCompletedSummary(completedCount, totalCount))
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
                                    width: max(0, geo.size.width * progressFraction),
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)
                }

                if let breakdown = breakdown, breakdown.total > 0 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            if breakdown.completed > 0 {
                                breakdownChip(
                                    count: breakdown.completed,
                                    label: L10n.Inbox.filterCompleted,
                                    icon: "checkmark.circle",
                                    color: AppColors.accentGreen
                                )
                            }
                            if breakdown.active > 0 {
                                breakdownChip(
                                    count: breakdown.active,
                                    label: L10n.Inbox.filterActive,
                                    icon: "circle.dotted",
                                    color: AppColors.warning
                                )
                            }
                            if breakdown.drafted > 0 {
                                breakdownChip(
                                    count: breakdown.drafted,
                                    label: L10n.Inbox.filterDrafted,
                                    icon: "circle.dashed",
                                    color: AppColors.textSecondary
                                )
                            }
                            if breakdown.cancelled > 0 {
                                breakdownChip(
                                    count: breakdown.cancelled,
                                    label: L10n.Inbox.filterCancelled,
                                    icon: "xmark.circle",
                                    color: AppColors.destructive
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    private func breakdownChip(count: Int, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)

            Text("\(count) \(label)")
                .font(AppFonts.caption2Bold)
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
    }
}

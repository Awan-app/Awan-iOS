//
//  GoalDetailSheet.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

public struct GoalDetailSheet: View {
    let goal: Goal
    let progressFraction: Double
    let completedCount: Int
    let totalCount: Int
    let breakdown: GoalTaskBreakdown?
    let onDismiss: () -> Void

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    public init(
        goal: Goal,
        progressFraction: Double = 0.0,
        completedCount: Int = 0,
        totalCount: Int = 0,
        breakdown: GoalTaskBreakdown? = nil,
        onDismiss: @escaping () -> Void
    ) {
        self.goal = goal
        self.progressFraction = progressFraction
        self.completedCount = completedCount
        self.totalCount = totalCount
        self.breakdown = breakdown
        self.onDismiss = onDismiss
    }

    public init(
        goalItem: GoalProgressItem,
        onDismiss: @escaping () -> Void
    ) {
        self.goal = goalItem.rawGoal
        self.progressFraction = goalItem.progressFraction
        self.completedCount = goalItem.completedCount
        self.totalCount = goalItem.totalCount
        self.breakdown = goalItem.breakdown
        self.onDismiss = onDismiss
    }

    private var progressColor: Color {
        if progressFraction >= 1.0 {
            return AppColors.accentGreen
        } else if progressFraction > 0.0 {
            return AppColors.accentBlue
        } else {
            return AppColors.textSecondary
        }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.sheetBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerCard

                        progressSection

                        if let description = goal.description, !description.isEmpty {
                            descriptionCard(description)
                        }

                        detailsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle(L10n.Inbox.tabGoals)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.close) {
                        onDismiss()
                    }
                    .font(AppFonts.subheadlineBold)
                    .foregroundStyle(AppColors.accentBlue)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var headerCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(goal.name)
                            .font(AppFonts.title2Black)
                            .foregroundStyle(AppColors.textPrimary)

                        if let deadline = goal.deadline {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppColors.accentBlue)

                                Text(Self.dateFormatter.string(from: deadline))
                                    .font(AppFonts.subheadlineSemibold)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                    }

                    Spacer()

                    statusBadge
                }
            }
        }
    }

    private var progressSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Progress")
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundStyle(AppColors.textSecondary)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(Int(progressFraction * 100))%")
                            .font(AppFonts.title2Black)
                            .foregroundStyle(progressColor)

                        Text("\(completedCount) of \(totalCount) tasks completed")
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
                                    label: "Completed",
                                    icon: "checkmark.circle",
                                    color: AppColors.accentGreen
                                )
                            }
                            if breakdown.active > 0 {
                                breakdownChip(
                                    count: breakdown.active,
                                    label: "Active",
                                    icon: "circle.dotted",
                                    color: AppColors.warning
                                )
                            }
                            if breakdown.drafted > 0 {
                                breakdownChip(
                                    count: breakdown.drafted,
                                    label: "Drafted",
                                    icon: "circle.dashed",
                                    color: AppColors.textSecondary
                                )
                            }
                            if breakdown.cancelled > 0 {
                                breakdownChip(
                                    count: breakdown.cancelled,
                                    label: "Cancelled",
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

    private var statusBadge: some View {
        Text(statusText)
            .font(AppFonts.captionHeavy)
            .foregroundStyle(statusColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.12))
            )
    }

    private var statusText: String {
        switch goal.status {
        case .active:
            return L10n.Inbox.filterActive
        case .completed:
            return L10n.Inbox.filterCompleted
        case .cancelled:
            return L10n.Inbox.filterCancelled
        }
    }

    private var statusColor: Color {
        switch goal.status {
        case .active:
            return AppColors.accentBlue
        case .completed:
            return AppColors.accentGreen
        case .cancelled:
            return AppColors.warning
        }
    }

    private func descriptionCard(_ description: String) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Home.description)
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundStyle(AppColors.textSecondary)

                Text(description)
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var detailsSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(AppColors.accentBlue)
                    Text("Created")
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                    Text(Self.dateFormatter.string(from: goal.createdAt))
                        .font(AppFonts.subheadlineBold)
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
        }
    }
}

#Preview("Goal Detail Sheet - Light") {
    GoalDetailSheet(
        goalItem: GoalProgressItem(
            id: UUID(),
            title: "Build Portfolio Website",
            description: "Design and implement personal portfolio with SwiftUI and modern web standards.",
            deadlineText: "Dec 31",
            progressFraction: 0.67,
            completedCount: 2,
            totalCount: 3,
            breakdown: GoalTaskBreakdown(drafted: 0, active: 1, completed: 2, cancelled: 0),
            rawGoal: Goal(
                id: UUID(),
                name: "Build Portfolio Website",
                description: "Design and implement personal portfolio with SwiftUI and modern web standards.",
                status: .active,
                deadline: Date().addingTimeInterval(86400 * 14)
            )
        ),
        onDismiss: {}
    )
}

#Preview("Goal Detail Sheet - Dark") {
    GoalDetailSheet(
        goalItem: GoalProgressItem(
            id: UUID(),
            title: "Learn Swift Concurrency",
            description: "Study async/await, actors, and Sendable protocol.",
            deadlineText: nil,
            progressFraction: 0.33,
            completedCount: 1,
            totalCount: 3,
            breakdown: GoalTaskBreakdown(drafted: 1, active: 1, completed: 1, cancelled: 0),
            rawGoal: Goal(
                id: UUID(),
                name: "Learn Swift Concurrency",
                description: "Study async/await, actors, and Sendable protocol.",
                status: .active,
                deadline: nil
            )
        ),
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}

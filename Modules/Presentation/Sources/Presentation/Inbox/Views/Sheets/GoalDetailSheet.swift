//
//  GoalDetailSheet.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

public struct GoalDetailSheet: View {
    let goal: Goal
    let onDismiss: () -> Void

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    public init(goal: Goal, onDismiss: @escaping () -> Void) {
        self.goal = goal
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.sheetBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerCard

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
        goal: Goal(
            id: UUID(),
            name: "Build Portfolio Website",
            description: "Design and implement personal portfolio with SwiftUI and modern web standards.",
            status: .active,
            deadline: Date().addingTimeInterval(86400 * 14)
        ),
        onDismiss: {}
    )
}

#Preview("Goal Detail Sheet - Dark") {
    GoalDetailSheet(
        goal: Goal(
            id: UUID(),
            name: "Learn Swift Concurrency",
            description: "Study async/await, actors, and Sendable protocol.",
            status: .active,
            deadline: nil
        ),
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}

//
//  GoalDetailHeaderCard.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct GoalDetailHeaderCard: View {
    let goal: Goal

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 24),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.outline.opacity(0.06),
            depthColor: AppColors.outline.opacity(0.10),
            borderWidth: 1.5,
            depthOffset: 4
        ) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(goal.name)
                            .font(AppFonts.headlineBlack)
                            .foregroundStyle(AppColors.textPrimary)

                        if let description = goal.description, !description.isEmpty {
                            Text(description)
                                .font(AppFonts.caption2Bold)
                                .foregroundStyle(AppColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 4)
                        }

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

                    statusBadge(goal.status)
                }
            }
        }
    }

    private func statusBadge(_ status: GoalStatus) -> some View {
        Text(statusText(status))
            .font(AppFonts.captionHeavy)
            .foregroundStyle(statusColor(status))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(statusColor(status).opacity(0.12))
            )
    }

    private func statusText(_ status: GoalStatus) -> String {
        switch status {
        case .active:
            return L10n.Inbox.filterActive
        case .completed:
            return L10n.Inbox.filterCompleted
        case .cancelled:
            return L10n.Inbox.filterCancelled
        }
    }

    private func statusColor(_ status: GoalStatus) -> Color {
        switch status {
        case .active:
            return AppColors.accentBlue
        case .completed:
            return AppColors.accentGreen
        case .cancelled:
            return AppColors.warning
        }
    }
}

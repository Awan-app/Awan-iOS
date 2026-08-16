//
//  GoalDetailScreenHeader.swift
//  Presentation
//

import Common
import SwiftUI

struct GoalDetailScreenHeader: View {
    let rewardPoints: Int?
    let pointsPulse: Int
    let canScheduleWithAI: Bool
    let onBack: () -> Void
    let onScheduleWithAI: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            AppBackButton(
                accessibilityLabel: L10n.CalendarScreen.back,
                onTap: onBack
            )

            Text(L10n.Goals.detailTitle)
                .font(AppFonts.title3Black)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .layoutPriority(1)

            Spacer(minLength: 0)

            if let rewardPoints {
                RewardStatChip(
                    icon: "star.fill",
                    value: rewardPoints.formatted(),
                    color: AppColors.reward,
                    isCompact: true
                )
                .symbolEffect(.bounce, value: pointsPulse)
                .anchorPreference(
                    key: RewardAnchorKey.self,
                    value: .bounds
                ) { anchor in
                    ["goal-points-badge": anchor]
                }
            }

            Menu {
                if canScheduleWithAI {
                    Button(action: onScheduleWithAI) {
                        Label(L10n.Goals.scheduleWithAI, systemImage: "sparkles")
                    }
                }

                Button(action: onEdit) {
                    Label(L10n.Goals.editButton, systemImage: "pencil")
                }

                Button(role: .destructive, action: onDelete) {
                    Label(L10n.Goals.deleteButton, systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(AppFonts.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(AppColors.surface, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(AppColors.outline.opacity(0.08), lineWidth: 1.5)
                    }
                    .background {
                        Circle()
                            .fill(AppColors.outline.opacity(0.12))
                            .offset(y: 3)
                    }
                    .padding(.bottom, 3)
            }
            .accessibilityLabel(L10n.Profile.more)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(AppColors.sheetBackground)
    }
}

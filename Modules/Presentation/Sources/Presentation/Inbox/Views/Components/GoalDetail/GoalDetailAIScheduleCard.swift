//
//  GoalDetailAIScheduleCard.swift
//  Presentation
//
//

import Common
import SwiftUI

struct GoalDetailAIScheduleCard: View {
    let isLoading: Bool
    let onSchedule: () -> Void

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 24),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.accentBlue.opacity(0.20),
            depthColor: AppColors.accentBlue.opacity(0.18),
            borderWidth: 1.5,
            depthOffset: 4,
            contentInsets: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        ) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppColors.accentBlue.opacity(0.18),
                                        AppColors.accentPurple.opacity(0.18)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)

                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.accentBlue, AppColors.accentPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Goals.scheduleWithAI)
                            .font(AppFonts.headlineBlack)
                            .foregroundStyle(AppColors.textPrimary)

                        Text(L10n.Goals.scheduleWithAISubtitle)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                AppButton(
                    title: L10n.Goals.scheduleWithAIButton,
                    icon: "sparkles",
                    color: AppColors.accentBlue,
                    isLoading: isLoading,
                    onTap: onSchedule
                )
            }
        }
    }
}

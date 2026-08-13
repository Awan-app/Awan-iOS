//
//  GoalPickerRow.swift
//  Presentation
//

import Common
import Domain
import SwiftUI

struct GoalPickerRow: View {
    let goal: Goal
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            AppDepthSurface(
                shape: .roundedRectangle(cornerRadius: 16),
                surfaceColor: AppColors.surface,
                borderColor: AppColors.outline.opacity(0.12),
                depthColor: AppColors.outline.opacity(0.08),
                borderWidth: 1.5,
                depthOffset: 3,
                contentInsets: EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
            ) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(AppColors.accentBlue.opacity(0.12))
                        .overlay(
                            Image(systemName: "target")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(AppColors.accentBlue)
                        )
                        .frame(width: 36, height: 36)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.name)
                            .font(AppFonts.headlineBlack)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)

                        if let description = goal.description, !description.isEmpty {
                            Text(description)
                                .font(AppFonts.subheadlineSemibold)
                                .foregroundStyle(AppColors.textSecondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer(minLength: 4)

                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppColors.accentBlue)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

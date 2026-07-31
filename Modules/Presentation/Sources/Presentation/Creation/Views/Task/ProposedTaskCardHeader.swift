//
//  ProposedTaskCardHeader.swift
//  Presentation
//

import Common
import SwiftUI

struct ProposedTaskCardHeader: View {
    let title: String
    let description: String?
    let isSelected: Bool
    let onToggleSelect: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggleSelect) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(
                        isSelected
                            ? AppColors.accentBlue
                            : AppColors.textSecondary.opacity(0.4)
                    )
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFonts.headlineBlack)
                    .foregroundStyle(AppColors.textPrimary)

                if let desc = description, !desc.isEmpty {
                    Text(desc)
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer()
        }
    }
}

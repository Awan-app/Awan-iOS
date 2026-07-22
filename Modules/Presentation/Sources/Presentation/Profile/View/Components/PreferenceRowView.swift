//
//  PreferenceRowView.swift
//  Presentation
//

import SwiftUI
import Common

/// A single tappable preference row: icon · title · value · chevron.
struct PreferenceRowView: View {
    let icon: String
    let title: String
    let value: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppColors.accentBlue)
                    .frame(width: 26, alignment: .center)

                Text(title)
                    .font(AppFonts.subheadlineBold)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Text(value)
                    .font(AppFonts.subheadlineSemibold)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.6))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

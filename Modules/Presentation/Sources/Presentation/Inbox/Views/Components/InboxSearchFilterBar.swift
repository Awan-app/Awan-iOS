//
//  InboxSearchFilterBar.swift
//  Presentation
//

import Common
import SwiftUI

struct InboxSearchFilterBar: View {
    @Binding var searchQuery: String

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.7))

                TextField(L10n.Inbox.searchPlaceholder, text: $searchQuery)
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .autocorrectionDisabled()

                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppColors.outline.opacity(0.12), lineWidth: 1.5)
            )

            Button {} label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.accentBlue)
                    .frame(width: 46, height: 46)
            }
            .buttonStyle(
                AppDepthButtonStyle(
                    shape: .roundedRectangle(cornerRadius: 16),
                    surfaceColor: AppColors.surface,
                    borderColor: AppColors.accentBlue.opacity(0.35),
                    depthColor: AppColors.accentBlueDepth.opacity(0.25),
                    borderWidth: 1.5,
                    depthOffset: 4,
                    pressedOffset: 2
                )
            )
            .accessibilityLabel("Filter options")
        }
    }
}

#Preview("Inbox Search Filter Bar Light") {
    InboxSearchFilterBar(searchQuery: .constant(""))
        .padding()
        .background(AppColors.screenBackground)
}

#Preview("Inbox Search Filter Bar Dark") {
    InboxSearchFilterBar(searchQuery: .constant("presentation"))
        .padding()
        .background(AppColors.screenBackground)
        .preferredColorScheme(.dark)
}

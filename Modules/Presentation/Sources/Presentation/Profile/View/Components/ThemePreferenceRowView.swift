//
//  ThemePreferenceRowView.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Common

/// A row with a segmented picker for Theme selection
struct ThemePreferenceRowView: View {
    let icon: String
    let title: String
    @Environment(AppearanceManager.self) private var appearanceManager

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColors.accentBlue)
                .frame(width: 26, alignment: .center)

            Text(title)
                .font(AppFonts.subheadlineBold)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            themePicker
        }
    }

    private var themePicker: some View {
        HStack(spacing: 0) {
            ForEach(AppAppearance.allCases, id: \.self) { theme in
                themeButton(for: theme)

                if theme != .dark {
                    Divider()
                        .frame(height: 12)
                }
            }
        }
        .padding(2)
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppColors.outline.opacity(0.15), lineWidth: 1)
        }
    }

    private func localizedTitle(for theme: AppAppearance) -> String {
        switch theme {
        case .light: return L10n.Profile.light
        case .dark: return L10n.Profile.dark
        case .system: return L10n.Profile.system
        }
    }

    private func themeButton(for theme: AppAppearance) -> some View {
        let isSelected = appearanceManager.currentAppearance == theme

        return Button {
            withAnimation(.snappy(duration: 0.2)) {
                appearanceManager.currentAppearance = theme
            }
        } label: {
            Text(localizedTitle(for: theme))
                .font(isSelected ? AppFonts.captionHeavy : AppFonts.subheadlineSemibold)
                .foregroundStyle(isSelected ? AppColors.accentBlue : AppColors.textSecondary)
                .padding(.vertical, 6)
                .frame(width: 58)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(AppColors.accentBlue.opacity(0.1))
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
}

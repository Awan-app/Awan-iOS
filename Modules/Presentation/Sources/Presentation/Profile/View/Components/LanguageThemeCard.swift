//
//  LanguageThemeCard.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Common

struct LanguageThemeCard: View {
    let language: String
    let onLanguageTap: () -> Void
    @Binding var selectedTheme: ThemePreferenceRowView.ThemeSelection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(title: L10n.Profile.languageAndAppearance, accentColor: AppColors.warning)

            DepthCardContainer {
                VStack(spacing: 0) {
                    PreferenceRowView(
                        icon: "globe",
                        title: L10n.Profile.language,
                        value: language,
                        onTap: onLanguageTap
                    )
                    .padding(.vertical, 6)

                    Divider()
                        .padding(.leading, 38)
                        .padding(.vertical, 8)

                    ThemePreferenceRowView(
                        icon: "circle.lefthalf.filled",
                        title: L10n.Profile.theme,
                        selectedTheme: $selectedTheme
                    )
                    .padding(.vertical, 6)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("LanguageThemeCard – Light") {
    @Previewable @State var theme: ThemePreferenceRowView.ThemeSelection = .light

    LanguageThemeCard(
        language: "English",
        onLanguageTap: {},
        selectedTheme: $theme
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.light)
}

#Preview("LanguageThemeCard – Dark") {
    @Previewable @State var theme: ThemePreferenceRowView.ThemeSelection = .dark

    LanguageThemeCard(
        language: "English",
        onLanguageTap: {},
        selectedTheme: $theme
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}

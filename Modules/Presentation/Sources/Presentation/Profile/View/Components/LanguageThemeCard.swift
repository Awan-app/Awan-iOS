//
//  LanguageThemeCard.swift
//  Presentation
//

import SwiftUI
import Common

struct LanguageThemeCard: View {
    let language: String
    let onLanguageTap: () -> Void
    @Binding var selectedTheme: ThemePreferenceRowView.ThemeSelection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(title: "LANGUAGE & APPEARANCE", accentColor: AppColors.warning)

            DepthCardContainer {
                VStack(spacing: 0) {
                    PreferenceRowView(
                        icon: "globe",
                        title: "Language",
                        value: language,
                        onTap: onLanguageTap
                    )

                    Divider()
                        .padding(.leading, 38)
                        .padding(.vertical, 8)

                    ThemePreferenceRowView(
                        icon: "circle.lefthalf.filled",
                        title: "Theme",
                        selectedTheme: $selectedTheme
                    )
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

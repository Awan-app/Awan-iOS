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
                        title: L10n.Profile.theme
                    )
                    .padding(.vertical, 6)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("LanguageThemeCard – Light") {
    @Previewable @State var appearanceManager = AppearanceManager()

    LanguageThemeCard(
        language: "English",
        onLanguageTap: {}
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.light)
    .environment(appearanceManager)
}

#Preview("LanguageThemeCard – Dark") {
    @Previewable @State var appearanceManager = AppearanceManager()

    LanguageThemeCard(
        language: "English",
        onLanguageTap: {}
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
    .environment(appearanceManager)
}

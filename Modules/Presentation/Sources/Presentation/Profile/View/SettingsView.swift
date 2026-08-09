import Common
import SwiftUI

struct SettingsView: View {
    @Environment(LanguageManager.self) private var languageManager
    @State private var isLanguageSheetPresented = false

    var body: some View {
        ZStack {
            AppColors.screenBackground
                .ignoresSafeArea()

            ScrollView {
                LanguageThemeCard(
                    language: languageManager.currentLanguage == .arabic
                        ? L10n.Profile.languageArabic
                        : L10n.Profile.languageEnglish,
                    onLanguageTap: {
                        isLanguageSheetPresented = true
                    }
                )
                .id(languageManager.currentLanguage)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(L10n.Profile.settings)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .sheet(isPresented: $isLanguageSheetPresented) {
            LanguageSelectionView()
        }
    }
}

#Preview("Language Appearance Light") {
    NavigationStack {
        SettingsView()
    }
    .environment(LanguageManager())
    .environment(AppearanceManager())
}

#Preview("Language Appearance Dark") {
    NavigationStack {
        SettingsView()
    }
    .environment(LanguageManager())
    .environment(AppearanceManager())
    .preferredColorScheme(.dark)
}

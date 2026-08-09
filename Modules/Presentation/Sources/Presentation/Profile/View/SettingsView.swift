import Common
import SwiftUI

struct SettingsView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(LanguageManager.self) private var languageManager
    @State private var isLanguageSheetPresented = false

    var body: some View {
        ZStack {
            AppColors.screenBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    LanguageThemeCard(
                        language: languageManager.currentLanguage == .arabic
                            ? L10n.Profile.languageArabic
                            : L10n.Profile.languageEnglish,
                        onLanguageTap: {
                            isLanguageSheetPresented = true
                        }
                    )

                    ProfileMenuCard(items: [
                        ProfileMenuItem(
                            icon: "info.circle.fill",
                            title: L10n.Profile.aboutAwan,
                            color: AppColors.accentGreen,
                            action: {
                                coordinator.mainCoordinator.push(MainRoute.aboutAwan)
                            }
                        )
                    ])
                }
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
    .environment(AppCoordinator())
    .environment(LanguageManager())
    .environment(AppearanceManager())
}

#Preview("Language Appearance Dark") {
    NavigationStack {
        SettingsView()
    }
    .environment(AppCoordinator())
    .environment(LanguageManager())
    .environment(AppearanceManager())
    .preferredColorScheme(.dark)
}

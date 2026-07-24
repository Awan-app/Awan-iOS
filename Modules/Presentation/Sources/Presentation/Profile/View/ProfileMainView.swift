//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Common
import Domain

struct ProfileMainView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(LanguageManager.self) private var languageManager
    @State private var selectedTheme: ThemePreferenceRowView.ThemeSelection = .light
    @State private var viewModel: ProfileViewModel
    @State private var isLanguageSheetPresented = false
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }

    private var formattedSessionTime: String {
        guard viewModel.sessionTime > 0 else { return "" }
        return "\(viewModel.sessionTime) min"
    }

    private var formattedSleepSchedule: String {
        guard let wake = viewModel.wakeupTime, let sleep = viewModel.sleepTime else { return "" }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = languageManager.locale
        
        var wakeComponents = DateComponents()
        wakeComponents.hour = wake.hour
        wakeComponents.minute = wake.minute
        
        var sleepComponents = DateComponents()
        sleepComponents.hour = sleep.hour
        sleepComponents.minute = sleep.minute
        
        guard let wakeDate = Calendar.current.date(from: wakeComponents),
              let sleepDate = Calendar.current.date(from: sleepComponents) else {
            return ""
        }
        
        return "\(formatter.string(from: sleepDate)) - \(formatter.string(from: wakeDate))"
    }

    var body: some View {
        ZStack {
            // Background
            AppColors.screenBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {

                    // Header Area
                    Text(L10n.Profile.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.brandDarkBlue)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                        .overlay(alignment: .trailing) {
                            GifImageView("Animated AWAN mascot")
                                .frame(width: 80, height: 80)
                                .padding(.trailing, 24)
                                .padding(.top, 40)
                        }

                    VStack(spacing: 10) {
                        PersonalInfoCard(
                            avatarImage: Image("user-avatar"), // Using actual asset
                            name: viewModel.userName,
                            email: viewModel.userEmail,
                            onEdit: {}
                        ).id(languageManager.currentLanguage)

                        // Daily Zones
                        DailyZonesCard(
                            zones: viewModel.dailyZones,
                            isReady: viewModel.isReady,
                            onTap: {}
                        ).id(languageManager.currentLanguage)

                        // Preferences
                        PreferencesCard(preferences: [
                            PreferenceItem(icon: "clock", title: L10n.Profile.sessionTime, value: formattedSessionTime, onTap: {
                                //go to session time view
                            }),
                            PreferenceItem(icon: "globe", title: L10n.Profile.timeZone, value: viewModel.timeZone, onTap: {
                                //go to time zone view
                            }),
                            PreferenceItem(icon: "moon", title: L10n.Profile.sleepSchedule, value: formattedSleepSchedule, onTap: {
                                //go to sleep schedule view
                            })
                        ])

                        // Language & Theme
                        LanguageThemeCard(
                            language: languageManager.currentLanguage == .arabic ? L10n.Profile.languageArabic : L10n.Profile.languageEnglish,
                            onLanguageTap: {
                                isLanguageSheetPresented = true
                            },
                            selectedTheme: $selectedTheme
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isLanguageSheetPresented) {
            LanguageSelectionView()
        }
        .task {
            await viewModel.fetchUserProfile()
        }
    }
}


#Preview {
    ProfileMainView(viewModel: ProfileViewModel(
        getUserProfileUseCase: MockGetUserProfileUseCase(),
        fetchZonesUseCase: MockFetchZonesUseCase()
    ))
}


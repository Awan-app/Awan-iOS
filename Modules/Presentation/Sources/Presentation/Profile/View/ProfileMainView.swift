//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Common

struct ProfileMainView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(LanguageManager.self) private var languageManager
    @State private var selectedTheme: ThemePreferenceRowView.ThemeSelection = .light
    @State private var viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
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
                            PreferenceItem(icon: "clock", title: L10n.Profile.sessionTime, value: L10n.Profile.dummySessionTime, onTap: {
                                //go to session time view
                            }),
                            PreferenceItem(icon: "globe", title: L10n.Profile.timeZone, value: L10n.Profile.dummyTimeZone, onTap: {
                                //go to time zone view
                            }),
                            PreferenceItem(icon: "moon", title: L10n.Profile.sleepSchedule, value: L10n.Profile.dummySleepSchedule, onTap: {
                                //go to sleep schedule view
                            })
                        ])

                        // Language & Theme
                        LanguageThemeCard(
                            language: languageManager.currentLanguage == .arabic ? L10n.Profile.languageArabic : L10n.Profile.languageEnglish,
                            onLanguageTap: {
                                coordinator.mainCoordinator.present(sheet: ProfileRoute.languageSelection)
                            },
                            selectedTheme: $selectedTheme
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.fetchUserProfile()
        }
    }
}

#if DEBUG
import Domain
import Combine

struct MockGetUserProfileUseCase: GetUserProfileUseCase {
    func execute() async throws -> UserProfile {
        UserProfile(
            id: UUID(),
            email: "mock@awan.app",
            firstName: "Mock",
            lastName: "User",
            birthDate: try! BirthDate(year: 1990, month: 1, day: 1),
            points: 100,
            streak: 5,
            maxStreak: 10,
            preferences: UserPreferences(
                timezone: "UTC",
                preferredSessionDuration: 60,
                bufferBetweenSessions: 10,
                wakeupTime: try! LocalTime(hour: 7, minute: 0),
                sleepTime: try! LocalTime(hour: 23, minute: 0)
            )
        )
    }
    func observe() -> AnyPublisher<UserProfile, Error> {
        Empty().eraseToAnyPublisher()
    }
}

#Preview {
    ProfileMainView(viewModel: ProfileViewModel(getUserProfileUseCase: MockGetUserProfileUseCase()))
}
#endif

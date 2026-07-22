//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Common

struct ProfileMainView: View {
    @State private var selectedTheme: ThemePreferenceRowView.ThemeSelection = .light
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        ZStack {
            // Background
            AppColors.screenBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {

                    // Header Area
                    Text("Profile")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.brandDarkBlue)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                        .overlay(alignment: .trailing) {
                            GifImageView("Animated AWAN mascot")
                                .frame(width: 80, height: 80)
                                .padding(.trailing, 24)
                        }

                    VStack(spacing: 10) {
                        // Personal Info
                        PersonalInfoCard(
                            avatarImage: Image("avatar-placeholder"), // Dummy image or nil
                            name: "Sam Rivera",
                            email: "sam@awan.app",
                            onEdit: {}
                        )

                        // Daily Zones
                        DailyZonesCard(
                            zones: viewModel.dailyZones,
                            isReady: viewModel.isReady,
                            onTap: {}
                        )

                        // Preferences
                        PreferencesCard(preferences: [
                            PreferenceItem(icon: "clock", title: "Session time", value: "60 min", onTap: {
                                //go to session time view
                            }),
                            PreferenceItem(icon: "globe", title: "Time zone", value: "Cairo · GMT+3", onTap: {
                                //go to time zone view
                            }),
                            PreferenceItem(icon: "moon", title: "Sleep schedule", value: "11:00 PM – 7:00 AM", onTap: {
                                //go to sleep schedule view
                            })
                        ])

                        // Language & Theme
                        LanguageThemeCard(
                            language: "English",
                            onLanguageTap: {
                                //go to change lan view
                            },
                            selectedTheme: $selectedTheme
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ProfileMainView()
}

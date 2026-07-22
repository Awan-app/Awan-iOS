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

    private let sampleColors: [Color] = [
        AppColors.accentPurple,
        AppColors.accentBlue,
        Color.orange,
        Color(red: 0.93, green: 0.26, blue: 0.26)
    ]

    var body: some View {
        ZStack {
            // Background
            AppColors.screenBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Header Area
                    HStack {
                        Spacer()
                        Text("Profile")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.brandDarkBlue)
                        Spacer()
                    }
                    .overlay(
                        HStack {
                            Spacer()
                            GifImageView("Animated AWAN mascot")
                                .frame(width: 80, height: 80)
                                .offset(x: 10, y: -10)
                        }
                    )
                    .padding(.top, 16)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                    VStack(spacing: 24) {
                        // Personal Info
                        PersonalInfoCard(
                            avatarImage: Image("avatar-placeholder"), // Dummy image or nil
                            name: "Sam Rivera",
                            email: "sam@awan.app",
                            onEdit: {}
                        )

                        // Daily Zones
                        DailyZonesCard(
                            zoneColors: sampleColors,
                            isReady: true,
                            onTap: {}
                        )

                        // Preferences
                        PreferencesCard(preferences: [
                            PreferenceItem(icon: "clock", title: "Session time", value: "60 min", onTap: {}),
                            PreferenceItem(icon: "globe", title: "Time zone", value: "Cairo · GMT+3", onTap: {}),
                            PreferenceItem(icon: "moon", title: "Sleep schedule", value: "11:00 PM – 7:00 AM", onTap: {})
                        ])

                        // Language & Theme
                        LanguageThemeCard(
                            language: "English",
                            onLanguageTap: {},
                            selectedTheme: $selectedTheme
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ProfileMainView()
}

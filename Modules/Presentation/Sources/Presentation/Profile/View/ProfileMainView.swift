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
    @State private var viewModel: ProfileViewModel
    var dailyZonesViewModel: DailyZonesViewModel
    @State private var isLanguageSheetPresented = false
    @State private var isSessionTimeSheetPresented = false
    @State private var isTimeZoneSheetPresented = false
    @State private var isSleepScheduleSheetPresented = false
    
    init(viewModel: ProfileViewModel, dailyZonesViewModel: DailyZonesViewModel) {
        self.viewModel = viewModel
        self.dailyZonesViewModel = dailyZonesViewModel
    }

    private var formattedSessionTime: String {
        guard viewModel.sessionTime > 0 else { return "" }
        return L10n.Home.minutesShort(viewModel.sessionTime)
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
                ZStack {
                    Text(L10n.Profile.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.brandDarkBlue)

                    HStack {
                        Spacer()

                        GifImageView("Animated AWAN mascot")
                            .frame(width: 64, height: 64)
                    }
                    .padding(.horizontal, 24)
                }
                .frame(height: 64)
                .background(AppColors.screenBackground)
                .zIndex(1)

                ScrollView {
                    VStack(spacing: 10) {
                        PersonalInfoCard(
                            avatarImage: Image("user-avatar"), // Using actual asset
                            name: viewModel.userName,
                            email: viewModel.userEmail,
                            onEdit: {
                                coordinator.mainCoordinator.push(MainRoute.userInfo)
                            }
                        ).id(languageManager.currentLanguage)

                        // Daily Zones
                        DailyZonesCard(
                            zones: viewModel.dailyZones,
                            isReady: viewModel.isReady,
                            onTap: {
                                coordinator.mainCoordinator.push(MainRoute.dailyZones)
                            }
                        ).id(languageManager.currentLanguage)

                        // Preferences
                        PreferencesCard(preferences: [
                            PreferenceItem(icon: "clock", title: L10n.Profile.sessionTime, value: formattedSessionTime, onTap: {
                                isSessionTimeSheetPresented = true
                            }),
                            PreferenceItem(icon: "globe", title: L10n.Profile.timeZone, value: viewModel.timeZone, onTap: {
                                isTimeZoneSheetPresented = true
                            }),
                            PreferenceItem(icon: "moon", title: L10n.Profile.sleepSchedule, value: formattedSleepSchedule, onTap: {
                                isSleepScheduleSheetPresented = true
                            })
                        ])

                        // Language & Theme
                        LanguageThemeCard(
                            language: languageManager.currentLanguage == .arabic ? L10n.Profile.languageArabic : L10n.Profile.languageEnglish,
                            onLanguageTap: {
                                isLanguageSheetPresented = true
                            }
                        )

                        // Logout
                        AppButton(
                            title: L10n.Profile.logout,
                            color: AppColors.destructive,
                            onTap: {
                                viewModel.showLogoutConfirmation = true
                            }
                        )
                        .padding(.top, 12)
                        .disabled(viewModel.isLoggingOut)

                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 90)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isLanguageSheetPresented) {
            LanguageSelectionView()
        }
        .alert(L10n.Profile.logout, isPresented: Bindable(viewModel).showLogoutConfirmation) {
            Button(L10n.Common.cancel, role: .cancel) {}
            Button(L10n.Profile.logout, role: .destructive) {
                Task {
                    await viewModel.logout()
                }
            }
        } message: {
            Text(L10n.Profile.logoutConfirmationMessage)
        }
        .sheet(isPresented: $isSessionTimeSheetPresented) {
            SessionTimeSheet(
                initialDuration: viewModel.sessionTime > 0 ? viewModel.sessionTime : 60,
                onSave: { newDuration in
                    Task {
                        await viewModel.updateSessionTime(newDuration)
                    }
                    isSessionTimeSheetPresented = false
                },
                onDismiss: {
                    isSessionTimeSheetPresented = false
                }
            )
            .presentationDetents([.height(360)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isTimeZoneSheetPresented) {
            TimeZoneSheet(
                currentTimeZone: viewModel.timeZone,
                onSave: { newTimezone in
                    Task {
                        await viewModel.updateTimezone(newTimezone)
                    }
                    isTimeZoneSheetPresented = false
                },
                onDismiss: {
                    isTimeZoneSheetPresented = false
                }
            )
            .presentationDetents([.height(500)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isSleepScheduleSheetPresented) {
            SleepScheduleSheet(
                initialWakeUpTime: viewModel.wakeupTime,
                initialSleepTime: viewModel.sleepTime,
                onSave: { wakeUpTime, sleepTime in
                    Task {
                        await viewModel.updateSleepSchedule(wakeUpTime: wakeUpTime, sleepTime: sleepTime)
                    }
                    isSleepScheduleSheetPresented = false
                },
                onDismiss: {
                    isSleepScheduleSheetPresented = false
                }
            )
            .presentationDetents([.height(360)])
            .presentationDragIndicator(.visible)
        }
        .task {
            await viewModel.fetchUserProfile()
        }
    }
}

#Preview {
    ProfileMainView(
        viewModel: ProfileViewModel(
            getUserProfileUseCase: MockGetUserProfileUseCase(),
            fetchZonesUseCase: MockFetchZonesUseCase(),
            logoutUseCase: LogoutUseCase(repository: MockAuthRepository()),
            updateSessionDurationUseCase: MockUpdateSessionDurationUseCase(),
            updateTimezoneUseCase: MockUpdateTimezoneUseCase(),
            updateSleepScheduleUseCase: MockUpdateSleepScheduleUseCase()
        ),
        dailyZonesViewModel: DailyZonesViewModel(
            useCases: DailyZonesUseCases(
                fetchTemplates: MockFetchTemplatesUseCase(),
                fetchOverrides: MockFetchTemplateOverridesUseCase(),
                createTemplate: MockCreateTemplateUseCase(),
                updateTemplateZones: MockUpdateTemplateUseCase(),
                updateTemplateDetails: MockUpdateTemplateDetailsUseCase(),
                deleteTemplate: MockDeleteTemplateUseCase(),
                createOverride: MockCreateTemplateOverrideUseCase(),
                updateOverrideZones: MockUpdateBulkTemplateOverrideUseCase(),
                updateOverrideDetails: MockUpdateTemplateOverrideUseCase(),
                deleteOverride: MockDeleteTemplateOverrideUseCase(),
                getUserProfile: MockGetUserProfileUseCase(),
                manageSchedule: DefaultManageDailyZoneScheduleUseCase(),
                resolveWeekdays: DefaultResolveTemplateWeekdayAvailabilityUseCase()
            )
        )
    )
}

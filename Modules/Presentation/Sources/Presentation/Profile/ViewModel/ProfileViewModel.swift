//
//  ProfileViewModel.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Observation
import Common
import Domain
import Combine


@MainActor
@Observable
public final class ProfileViewModel {
    
    // MARK: - State
    
    /// The user's zones fetched from the backend, mapped to the Domain model.
    var dailyZones: [Zone] = []
    
    /// Indicates if the profile data is fully loaded and ready
    var isReady: Bool = false
    
    /// Indicates if a logout operation is in progress
    var isLoggingOut: Bool = false
    
    /// Controls the presentation of the logout confirmation alert
    var showLogoutConfirmation: Bool = false
    
    /// User's real name and email
    var userName: String = ""
    var userEmail: String = ""
    
    // MARK: - Profile Preferences
    var sessionTime: Int = 0
    var timeZone: String = ""
    var wakeupTime: LocalTime? = nil
    var sleepTime: LocalTime? = nil
    
    @ObservationIgnored private var fetchZonesCancellable: AnyCancellable?
    
    // MARK: - Init
    
    private let getUserProfileUseCase: GetUserProfileUseCase
    private let updateSessionDurationUseCase: any UpdateSessionDurationUseCase
    private let updateTimezoneUseCase: any UpdateTimezoneUseCase
    private let updateSleepScheduleUseCase: any UpdateSleepScheduleUseCase
    private let fetchZonesUseCase: FetchZonesUseCase
    private let logoutUseCase: LogoutUseCase
    private let onLogout: (() -> Void)?
    
    public init(
        getUserProfileUseCase: GetUserProfileUseCase,
        fetchZonesUseCase: FetchZonesUseCase,
        logoutUseCase: LogoutUseCase,
        updateSessionDurationUseCase: any UpdateSessionDurationUseCase,
        updateTimezoneUseCase: any UpdateTimezoneUseCase,
        updateSleepScheduleUseCase: any UpdateSleepScheduleUseCase,
        onLogout: (() -> Void)? = nil
    ) {
        self.getUserProfileUseCase = getUserProfileUseCase
        self.updateSessionDurationUseCase = updateSessionDurationUseCase
        self.updateTimezoneUseCase = updateTimezoneUseCase
        self.fetchZonesUseCase = fetchZonesUseCase
        self.logoutUseCase = logoutUseCase
        self.updateSleepScheduleUseCase = updateSleepScheduleUseCase
        self.onLogout = onLogout
        
        Task {
            await fetchUserProfile()
        }
    }
    
    // MARK: - Actions
    
    /// Fetch real user profile from backend via domain use case
    public func fetchUserProfile() async {
        do {
            let profile = try await getUserProfileUseCase.execute()
            applyUserProfile(profile)
            
            // Fetch daily zones AFTER profile is cached locally
            fetchDailyZones()
        } catch {
            print("Failed to fetch user profile: \(error)")
        }
    }

    /// Update session time via updateProfilePartial backend endpoint
    public func updateSessionTime(_ newDuration: Int) async {
        do {
            let updatedProfile = try await updateSessionDurationUseCase.execute(newDuration)
            applyUserProfile(updatedProfile)
        } catch {
            print("Failed to update session duration via API: \(error)")
        }
    }

    /// Update time zone via updateProfilePartial backend endpoint
    public func updateTimezone(_ newTimezone: String) async {
        do {
            let updatedProfile = try await updateTimezoneUseCase.execute(newTimezone)
            applyUserProfile(updatedProfile)
        } catch {
            print("Failed to update timezone via API: \(error)")
        }
    }
    public func updateSleepSchedule(wakeUpTime: String, sleepTime: String) async {
        do {
            let updatedProfile = try await updateSleepScheduleUseCase.execute(wakeUpTime: wakeUpTime, sleepTime: sleepTime)
            applyUserProfile(updatedProfile)
        } catch {
            print("Failed to update sleep schedule via API: \(error)")
        }
    }
    
  

    public func updateSleepSchedule(_ sleepTime: String) async {
        do {
            let updatedProfile = try await updateSleepScheduleUseCase.updateSleepTime(sleepTime)
            applyUserProfile(updatedProfile)
        } catch {
            print("Failed to update sleep time via API: \(error)")
        }
    }
    
    public func updateWakeUpSchedule(_ wakeUp: String) async {
        do {
            let updatedProfile = try await updateSleepScheduleUseCase.updateWakeUpTime(wakeUp)
            applyUserProfile(updatedProfile)
        } catch {
            print("Failed to update wakeup time via API: \(error)")
        }
    }



    private func applyUserProfile(_ profile: UserProfile) {
        self.userName = profile.firstName + " " + profile.lastName
        self.userEmail = profile.email
        self.sessionTime = profile.preferences.preferredSessionDuration
        self.timeZone = profile.preferences.timezone
        self.wakeupTime = profile.preferences.wakeupTime
        self.sleepTime = profile.preferences.sleepTime
    }

    private func fetchDailyZones() {
        fetchZonesCancellable?.cancel()
        fetchZonesCancellable = fetchZonesUseCase.observe(for: Date())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] zones in
                    self?.dailyZones = zones
                    self?.isReady = true
                }
            )
    }
    
    public func logout() async {
        isLoggingOut = true
        do {
            try await logoutUseCase.execute()
            onLogout?()
        } catch {
            print("Failed to logout: \(error)")
        }
        isLoggingOut = false
    }
}

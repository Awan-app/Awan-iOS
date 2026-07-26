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
    private let fetchZonesUseCase: FetchZonesUseCase
    private let logoutUseCase: LogoutUseCase
    
    public init(
        getUserProfileUseCase: GetUserProfileUseCase,
        fetchZonesUseCase: FetchZonesUseCase,
        logoutUseCase: LogoutUseCase
    ) {
        self.getUserProfileUseCase = getUserProfileUseCase
        self.fetchZonesUseCase = fetchZonesUseCase
        self.logoutUseCase = logoutUseCase
    }
    
    // MARK: - Actions
    
    /// Fetch real user profile from backend via domain use case
    public func fetchUserProfile() async {
        do {
            let profile = try await getUserProfileUseCase.execute()
            self.userName = profile.firstName + " " + profile.lastName
            self.userEmail = profile.email
            self.sessionTime = profile.preferences.preferredSessionDuration
            self.timeZone = profile.preferences.timezone
            self.wakeupTime = profile.preferences.wakeupTime
            self.sleepTime = profile.preferences.sleepTime
            
            // Fetch daily zones AFTER profile is cached locally
            fetchDailyZones()
        } catch {
            print("Failed to fetch user profile: \(error)")
        }
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
        } catch {
            print("Failed to logout: \(error)")
        }
        isLoggingOut = false
    }
}

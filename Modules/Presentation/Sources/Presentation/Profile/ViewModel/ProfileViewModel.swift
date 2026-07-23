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


@MainActor
@Observable
public final class ProfileViewModel {
    
    // MARK: - State
    
    /// The user's zones fetched from the backend, mapped to the Domain model.
    var dailyZones: [Zone] = []
    
    /// Indicates if the profile data is fully loaded and ready
    var isReady: Bool = false
    
    /// User's real name and email
    var userName: String = ""
    var userEmail: String = ""
    
    // MARK: - Init
    
    private let getUserProfileUseCase: GetUserProfileUseCase
    
    public init(getUserProfileUseCase: GetUserProfileUseCase) {
        self.getUserProfileUseCase = getUserProfileUseCase
        loadMockData()
    }
    
    // MARK: - Actions
    
    /// Temporary method to simulate loading dynamic zones from a backend
    private func loadMockData() {
        // Simulate domain entities that would normally be mapped from ZoneResponseDTO in the Data layer
        do {
            self.dailyZones = [
                Zone(
                    id: UUID(),
                    name: "eat",
                    color: try ZoneColor(hex: "#7459D9"), // accentPurple approx
                    startTime: try LocalTime(hour: 9, minute: 0),
                    endTime: try LocalTime(hour: 11, minute: 0)
                ),
                Zone(
                    id: UUID(),
                    name: "Meetings",
                    color: try ZoneColor(hex: "#3F8CFA"), // accentBlue approx
                    startTime: try LocalTime(hour: 11, minute: 30),
                    endTime: try LocalTime(hour: 13, minute: 0)
                ),
                Zone(
                    id: UUID(),
                    name: "Learning",
                    color: try ZoneColor(hex: "#FFA500"), // orange
                    startTime: try LocalTime(hour: 14, minute: 0),
                    endTime: try LocalTime(hour: 15, minute: 0)
                ),
                Zone(
                    id: UUID(),
                    name: "Admin",
                    color: try ZoneColor(hex: "#ED4242"), // red
                    startTime: try LocalTime(hour: 16, minute: 0),
                    endTime: try LocalTime(hour: 17, minute: 0)
                ),
                Zone(
                    id: UUID(),
                    name: "Deep Work",
                    color: try ZoneColor(hex: "#7459D9"), // accentPurple approx
                    startTime: try LocalTime(hour: 9, minute: 0),
                    endTime: try LocalTime(hour: 11, minute: 0)
                ),
            ]
        } catch {
            print("Error initializing mock zone colors or times: \(error)")
        }
        
        self.isReady = true
    }
    
    /// Fetch real user profile from backend via domain use case
    public func fetchUserProfile() async {
        do {
            let profile = try await getUserProfileUseCase.execute()
            self.userName = profile.firstName + " " + profile.lastName
            self.userEmail = profile.email
        } catch {
            print("Failed to fetch user profile: \(error)")
        }
    }
}

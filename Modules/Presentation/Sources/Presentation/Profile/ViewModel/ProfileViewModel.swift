//
//  ProfileViewModel.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Observation
import Common

/// A model representing a daily zone from the backend.
struct ZoneItem: Identifiable, Equatable {
    let id: UUID
    let name: String
    let color: Color
    
    init(id: UUID = UUID(), name: String, color: Color) {
        self.id = id
        self.name = name
        self.color = color
    }
}

@MainActor
@Observable
final class ProfileViewModel {
    
    // MARK: - State
    
    /// The user's zones fetched from the backend
    var dailyZones: [ZoneItem] = []
    
    /// Indicates if the profile data is fully loaded and ready
    var isReady: Bool = false
    
    // MARK: - Init
    
    init() {
        loadMockData()
    }
    
    // MARK: - Actions
    
    /// Temporary method to simulate loading dynamic zones from a backend
    private func loadMockData() {
        // Simulate a slight network delay or just load instantly for now
        self.dailyZones = [
            ZoneItem(name: "Deep Work", color: AppColors.accentPurple),
            ZoneItem(name: "Meetings", color: AppColors.accentBlue),
            ZoneItem(name: "Learning", color: .orange),
            ZoneItem(name: "Admin", color: Color(red: 0.93, green: 0.26, blue: 0.26))
        ]
        
        // Example of a 6-zone dynamic mock:
        // self.dailyZones = [
        //     ZoneItem(name: "Morning Focus", color: AppColors.accentPurple),
        //     ZoneItem(name: "Team Sync", color: AppColors.accentBlue),
        //     ZoneItem(name: "Lunch", color: .yellow),
        //     ZoneItem(name: "Deep Work", color: .orange),
        //     ZoneItem(name: "Emails", color: Color(red: 0.93, green: 0.26, blue: 0.26)),
        //     ZoneItem(name: "Wind Down", color: .mint)
        // ]
        
        self.isReady = true
    }
}

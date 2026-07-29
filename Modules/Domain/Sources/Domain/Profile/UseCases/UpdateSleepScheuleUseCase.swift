//
//  File.swift
//  Domain
//
//  Created by AndrewMagdy on 25/07/2026.
//

import Foundation

public protocol UpdateSleepScheduleUseCase: Sendable {
    func updateSleepTime(_ sleepTime: String) async throws -> UserProfile
    func updateWakeUpTime(_ wakeUpTime: String) async throws -> UserProfile
    func execute(wakeUpTime: String, sleepTime: String) async throws -> UserProfile

}

public struct DefaultUpdateSleepScheduleUseCase: UpdateSleepScheduleUseCase {
    private let repository: any UserProfileRepository

    public init(repository: any UserProfileRepository) {
        self.repository = repository
    }
    
    public func updateSleepTime(_ sleepTime: String) async throws -> UserProfile {
        try await repository.updateSleepSchedule(sleepTime)
    }
    
    public func updateWakeUpTime(_ wakeUpTime: String) async throws -> UserProfile {
        try await repository.updateWakeUpSchedule(wakeUpTime)
    }
    public func execute(wakeUpTime: String, sleepTime: String) async throws -> UserProfile {
           try await repository.updateSleepSchedule(wakeUpTime: wakeUpTime, sleepTime: sleepTime)
       }

    
}

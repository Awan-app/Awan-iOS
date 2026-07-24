//
//  Swift.swift
//  Presentation
//
//  Created by AndrewMagdy on 23/07/2026.
//

import Foundation
import Combine

public struct MockCompleteOnboardingUseCase: CompleteOnboardingUseCase {
    public init() {}
    public func execute(_ request: CompleteOnboardingRequest) async throws -> UserProfile {
        fatalError("Not implemented in preview mock")
    }
}

public struct MockCreateOnboardingTemplateUseCase: CreateOnboardingTemplateUseCase {
    public init() {}
    public func execute(zoneDrafts: [Zone]) async throws {}
}

public struct MockGetUserProfileUseCase: GetUserProfileUseCase {
    public init() {}
    public func execute() async throws -> UserProfile {
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
    public func observe() -> AnyPublisher<UserProfile, Error> {
        Empty().eraseToAnyPublisher()
    }
}

public struct MockFetchZonesUseCase: FetchZonesUseCase {
    public init() {}
    public func execute(for date: Date) async throws -> [Zone] {
        return Zone.mockDailyZones
    }
    public func observe(for date: Date) -> AnyPublisher<[Zone], Error> {
        Just(Zone.mockDailyZones).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

public extension Zone {
    static var mockDailyZones: [Zone] {
        do {
            return [
                Zone(
                    id: UUID(),
                    name: "eat",
                    color: try ZoneColor(hex: "#7459D9"),
                    startTime: try LocalTime(hour: 9, minute: 0),
                    endTime: try LocalTime(hour: 11, minute: 0)
                ),
                Zone(
                    id: UUID(),
                    name: "Meetings",
                    color: try ZoneColor(hex: "#3F8CFA"),
                    startTime: try LocalTime(hour: 11, minute: 30),
                    endTime: try LocalTime(hour: 13, minute: 0)
                ),
                Zone(
                    id: UUID(),
                    name: "Learning",
                    color: try ZoneColor(hex: "#FFA500"),
                    startTime: try LocalTime(hour: 14, minute: 0),
                    endTime: try LocalTime(hour: 15, minute: 0)
                ),
                Zone(
                    id: UUID(),
                    name: "Admin",
                    color: try ZoneColor(hex: "#ED4242"),
                    startTime: try LocalTime(hour: 16, minute: 0),
                    endTime: try LocalTime(hour: 17, minute: 0)
                ),
                Zone(
                    id: UUID(),
                    name: "Deep Work",
                    color: try ZoneColor(hex: "#7459D9"),
                    startTime: try LocalTime(hour: 9, minute: 0),
                    endTime: try LocalTime(hour: 11, minute: 0)
                )
            ]
        } catch {
            return []
        }
    }
}

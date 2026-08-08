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

public struct MockCreateAITaskUseCase: CreateAITaskUseCase {
    public init() {}
    public func execute(_ request: CreateAITaskRequest) async throws -> TaskProposal {
        fatalError("Not implemented in preview mock")
    }
}

public struct MockCreateOnboardingTemplateUseCase: CreateOnboardingTemplateUseCase {
    public init() {}
    public func execute(zoneDrafts: [Zone]) async throws {}
}

public extension UserProfile {
    static var mock: UserProfile {
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
}

public struct MockGetUserProfileUseCase: GetUserProfileUseCase {
    public init() {}
    public func execute() async throws -> UserProfile {
        UserProfile.mock
    }
    public func observe() -> AnyPublisher<UserProfile, Error> {
        Empty().eraseToAnyPublisher()
    }
}

public struct MockUpdateUserProfileUseCase: UpdateUserProfileUseCase {
    public init() {}
    public func execute(firstName: String?, lastName: String?, birthDate: String?) async throws {}
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

public struct MockFetchCategoriesUseCase: FetchCategoriesUseCase {
    public init() {}
    public func observe() -> AnyPublisher<[TaskCategory], Error> {
        Just([
            TaskCategory(id: UUID(), name: "General"),
            TaskCategory(id: UUID(), name: "Work"),
        ])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
}

public struct MockCreateCategoryUseCase: CreateCategoryUseCase {
    public init() {}
    public func execute(name: String) async throws -> TaskCategory {
        TaskCategory(id: UUID(), name: name)
    }
}

public struct MockFetchTemplatesUseCase: FetchTemplatesUseCase {
    public init() {}
    public func execute() async throws -> [Template] {
        return []
    }
}

public struct MockFetchTemplateOverridesUseCase: FetchTemplateOverridesUseCase {
    public init() {}
    public func execute() async throws -> [TemplateOverride] { [] }
}

public struct MockCreateTemplateUseCase: CreateTemplateUseCase {
    public init() {}
    public func execute(
        name: String,
        daysOfWeek: Set<TemplateWeekday>,
        zones: [Zone]
    ) async throws -> Template {
        fatalError("Not implemented in preview mock")
    }
}

public struct MockUpdateTemplateUseCase: UpdateTemplateUseCase {
    public init() {}
    public func execute(id: UUID, zones: [TemplateZoneMutation]) async throws -> Template {
        fatalError("Not implemented in preview mock")
    }
}

public struct MockUpdateTemplateDetailsUseCase: UpdateTemplateDetailsUseCase {
    public init() {}
    public func execute(
        id: UUID,
        name: String,
        daysOfWeek: Set<TemplateWeekday>
    ) async throws -> Template {
        fatalError("Not implemented in preview mock")
    }
}

public struct MockDeleteTemplateUseCase: DeleteTemplateUseCase {
    public init() {}
    public func execute(id: UUID) async throws {
        fatalError("Not implemented in preview mock")
    }
}

public struct MockDeleteTemplateOverrideUseCase: DeleteTemplateOverrideUseCase {
    public init() {}
    public func execute(id: UUID) async throws {
        fatalError("Not implemented in preview mock")
    }
}

public struct MockCreateTemplateOverrideUseCase: CreateTemplateOverrideUseCase {
    public init() {}
    public func execute(
        name: String,
        dateOfDay: TemplateOverrideDate,
        minimumDate: TemplateOverrideDate,
        zones: [Zone]?
    ) async throws -> TemplateOverride {
        fatalError("Not implemented in preview mock")
    }
}

public struct MockUpdateTemplateOverrideUseCase: UpdateTemplateOverrideUseCase {
    public init() {}
    public func execute(
        id: UUID,
        name: String,
        dateOfDay: TemplateOverrideDate,
        minimumDate: TemplateOverrideDate
    ) async throws -> TemplateOverride {
        fatalError("Not implemented in preview mock")
    }
}

public struct MockUpdateBulkTemplateOverrideUseCase: UpdateBulkTemplateOverrideUseCase {
    public init() {}
    public func execute(
        id: UUID,
        zones: [TemplateZoneMutation]
    ) async throws -> TemplateOverride {
        fatalError("Not implemented in preview mock")
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

public struct MockRequestOTPUseCase: RequestOTPUseCase {
    public init() {}
    public func execute(email: String) async throws -> OTPRequestResult {
        return OTPRequestResult(expiresInSeconds: 60, resendAvailableInSeconds: 60)
    }
}

public struct MockAuthRepository: AuthRepository {
    public init() {}
    public func requestOTP(email: String) async throws -> OTPRequestResult {
        return OTPRequestResult(expiresInSeconds: 60, resendAvailableInSeconds: 60)
    }
    public func verifyOTP(email: String, code: String) async throws -> VerifyOTPResult {
        return VerifyOTPResult(user: UserEntity(id: "1", email: "test@test.com", isNew: false))
    }
    public func signInWithGoogle(idToken: String, accessToken: String) async throws -> VerifyOTPResult {
        return VerifyOTPResult(user: UserEntity(id: "1", email: "google@test.com", isNew: false))
    }
    public func observeAuthenticatedUser() -> AsyncStream<UserEntity?> {
        AsyncStream { continuation in
            continuation.yield(UserEntity(id: "1", email: "test@test.com", isNew: false))
            continuation.finish()
        }
    }
    public func logout() async throws {}
}

public extension Date {
    static var mockWakeTime: Date {
        Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? .now
    }
    
    static var mockSleepTime: Date {
        Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? .now
    }
}


import Combine

public struct MockFetchTasksUseCase: FetchTasksUseCase {
    public init() {}
    public func execute(for date: Date) async throws -> [AwanTask] {
        return []
    }
    public func observe(for date: Date) -> AnyPublisher<[AwanTask], Error> {
        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

public struct MockFetchSessionsUseCase: FetchSessionsUseCase {
    public init() {}
    public func execute(for date: Date) async throws -> [Session] {
        return []
    }
    public func observe(for date: Date) -> AnyPublisher<[Session], Error> {
        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

public struct MockRescheduleSessionUseCase: RescheduleSessionUseCase {
    public init() {}
    public func execute(sessionID: UUID, newStart: Date) async throws -> Session {
        fatalError()
    }
}

public struct MockSetSessionLockUseCase: SetSessionLockUseCase {
    public init() {}
    public func execute(sessionID: UUID, isLocked: Bool) async throws -> Session {
        fatalError()
    }
}

public struct MockSetSessionCompletionUseCase: SetSessionCompletionUseCase {
    public init() {}
    public func execute(sessionID: UUID, isCompleted: Bool) async throws -> Session {
        fatalError()
    }
}

public struct MockDeleteSessionUseCase: DeleteSessionUseCase {
    public init() {}
    public func execute(sessionID: UUID) async throws {}
}

public struct MockCreateTaskUseCase: CreateTaskUseCase {
    public init() {}
    public func execute(_ request: CreateTaskRequest) async throws -> ScheduleOperationResult {
        fatalError()
    }
}



public struct MockManageZoneScheduleUseCase: ManageZoneScheduleUseCase {
    public init() {}
    public func swapZones(_ zones: [Zone], at sourceIndex: Int, with destinationIndex: Int) -> [Zone] { return zones }
    public func sortedChronologically(_ zones: [Zone]) -> [Zone] { return zones }
    public func isOverlapping(start: String, end: String, in zones: [Zone], excludingID: UUID?) -> Bool { return false }
    public func isOutsideActiveHours(start: Date, end: Date, wakeupTime: Date, sleepTime: Date) -> Bool { return false }
    public func firstAvailableInterval(wakeupTime: Date, existingZones: [Zone]) -> (start: Date, end: Date) { return (Date(), Date().addingTimeInterval(3600)) }
    public func formatTime(_ date: Date) -> String { return "10:00 AM" }
    public func parseTime(_ timeString: String) -> Date? { return Date() }
}


public extension AwanTask {
    static var mock: AwanTask {
        AwanTask(
            id: UUID(),
            title: "Mock Task",
            description: "Mock Task Description",
            status: .inProgress,
            goalID: nil,
            duration: try! TaskDuration(minutes: 60),
            isSplittable: false,
            mandatory: false,
            estimatedPoints: 10
        )
    }
}

public extension AITaskSheetItem {
    static var mock: AITaskSheetItem {
        AITaskSheetItem(
            task: AwanTask(
                id: UUID(),
                title: "Build login page",
                description: "Create a login page with email and password fields",
                status: .pending,
                goalID: UUID(),
                duration: try! TaskDuration(minutes: 60),
                isSplittable: false,
                mandatory: true,
                estimatedPoints: 20,
                dependencyIDs: [],
                category: TaskCategory(id: UUID(), name: "Study")
            ),
            startTime: Date()
        )
    }
}

public struct MockUpdateSessionDurationUseCase: UpdateSessionDurationUseCase {
    public init() {}
    public func execute(_ durationMinutes: Int) async throws -> UserProfile {
        UserProfile.mock
    }
}

public struct MockUpdateTimezoneUseCase: UpdateTimezoneUseCase {
    public init() {}
    public func execute(_ timezone: String) async throws -> UserProfile {
        UserProfile.mock
    }
}

public struct MockUpdateSleepScheduleUseCase: UpdateSleepScheduleUseCase {
    public init() {}
    public func updateSleepTime(_ sleepTime: String) async throws -> UserProfile { UserProfile.mock }
    public func updateWakeUpTime(_ wakeUpTime: String) async throws -> UserProfile { UserProfile.mock }
    public func execute(wakeUpTime: String, sleepTime: String) async throws -> UserProfile { UserProfile.mock }
}

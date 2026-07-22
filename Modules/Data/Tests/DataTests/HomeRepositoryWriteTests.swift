import Combine
import Domain
import Foundation
import SwiftData
import XCTest
@testable import Data

final class HomeRepositoryWriteTests: XCTestCase {
    func testSessionObservationEmitsCachedValueThenRemoteValue() async throws {
        let task = try AwanTask(
            id: UUID(),
            title: "Task",
            duration: TaskDuration(minutes: 60),
            isSplittable: false
        )
        let cached = Session(
            id: UUID(),
            taskID: task.id,
            zoneID: nil,
            timeRange: try TimeRange(start: date(hour: 9), end: date(hour: 10)),
            blocking: false,
            status: .planned
        )
        let remoteID = UUID()
        let container = try makeContainer()
        let sessions = SwiftDataSessionDataSource(modelContainer: container)
        let tasks = SwiftDataTaskDataSource(modelContainer: container)
        let profiles = SwiftDataUserProfileDataSource(modelContainer: container)
        try await tasks.addTask(task)
        try await sessions.addSession(cached)
        try await profiles.replaceProfile(profile())
        let remote = TestRemoteSessionDataSource(
            sessions: [
                SessionResponseDTO(
                    id: remoteID,
                    start: "2026-07-22T12:00:00",
                    end: "2026-07-22T13:00:00",
                    status: "SCHEDULED",
                    locked: false,
                    zoneId: nil
                )
            ],
            deleteFails: false
        )
        let repository = DefaultSessionRepository(
            localDataSource: sessions,
            localTaskDataSource: tasks,
            localProfileDataSource: profiles,
            remoteDataSource: remote
        )

        var iterator = repository.observeSessions(taskIDs: [task.id]).values.makeAsyncIterator()
        let cachedEmission = try await iterator.next()
        let remoteEmission = try await iterator.next()

        XCTAssertEqual(cachedEmission, [cached])
        XCTAssertEqual(remoteEmission?.map(\.id), [remoteID])
    }

    func testSessionDeleteFailureLeavesLocalCacheUnchanged() async throws {
        let task = try AwanTask(
            id: UUID(),
            title: "Task",
            duration: TaskDuration(minutes: 60),
            isSplittable: false
        )
        let session = Session(
            id: UUID(),
            taskID: task.id,
            zoneID: nil,
            timeRange: try TimeRange(start: date(hour: 10), end: date(hour: 11)),
            blocking: false,
            status: .planned
        )
        let container = try makeContainer()
        let sessions = SwiftDataSessionDataSource(modelContainer: container)
        let tasks = SwiftDataTaskDataSource(modelContainer: container)
        let profiles = SwiftDataUserProfileDataSource(modelContainer: container)
        try await tasks.addTask(task)
        try await sessions.addSession(session)
        try await profiles.replaceProfile(profile())
        let remote = TestRemoteSessionDataSource(sessions: [], deleteFails: true)
        let repository = DefaultSessionRepository(
            localDataSource: sessions,
            localTaskDataSource: tasks,
            localProfileDataSource: profiles,
            remoteDataSource: remote
        )

        do {
            try await repository.deleteSession(id: session.id)
            XCTFail("Expected remote deletion to fail")
        } catch is RepositoryWriteTestError {
            // Expected.
        }

        let cachedSessions = try await sessions.fetchSessions()
        XCTAssertEqual(cachedSessions, [session])
        let deletedIDs = await remote.deletedSessionIDs()
        XCTAssertEqual(deletedIDs, [session.id])
    }

    private func profile() throws -> UserProfile {
        UserProfile(
            id: UUID(),
            email: "home@awan.app",
            firstName: "Home",
            lastName: "User",
            birthDate: try BirthDate(year: 2000, month: 1, day: 1),
            points: 0,
            streak: 0,
            maxStreak: 0,
            preferences: UserPreferences(
                timezone: "UTC",
                preferredSessionDuration: 60,
                bufferBetweenSessions: 10,
                wakeupTime: try LocalTime(hour: 8, minute: 0),
                sleepTime: try LocalTime(hour: 0, minute: 0)
            )
        )
    }

    private func date(hour: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar.date(
            from: DateComponents(year: 2026, month: 7, day: 22, hour: hour)
        ) ?? .distantPast
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = SchedulingPersistence.schema
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

private enum RepositoryWriteTestError: Error {
    case remoteFailure
}

private actor TestRemoteSessionDataSource: RemoteSessionDataSourceProtocol {
    private var deletedIDs: [UUID] = []
    private let sessions: [SessionResponseDTO]
    private let deleteFails: Bool

    init(sessions: [SessionResponseDTO], deleteFails: Bool) {
        self.sessions = sessions
        self.deleteFails = deleteFails
    }

    func deletedSessionIDs() -> [UUID] { deletedIDs }

    func deleteSession(sessionID: UUID) throws {
        deletedIDs.append(sessionID)
        if deleteFails { throw RepositoryWriteTestError.remoteFailure }
    }

    func getSession(sessionID: UUID) throws -> SessionResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func updateSession(
        sessionID: UUID,
        request: UpdateSessionRequestDTO
    ) throws -> SessionResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func updateSessionStatus(sessionID: UUID, status: String) throws -> SessionResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func lockSession(sessionID: UUID) throws -> SessionResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func unlockSession(sessionID: UUID) throws -> SessionResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func createTaskWithSessions(
        request: CreateTaskWithSessionsRequestDTO
    ) throws -> TaskWithSessionsResponseDTO {
        throw RepositoryWriteTestError.remoteFailure
    }
    func getTaskSessions(taskID: UUID) -> [SessionResponseDTO] { sessions }
}

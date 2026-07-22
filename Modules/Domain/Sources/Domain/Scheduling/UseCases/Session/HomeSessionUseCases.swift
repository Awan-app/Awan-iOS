import Foundation

public protocol RescheduleSessionUseCase: Sendable {
    func execute(sessionID: UUID, newStart: Date) async throws -> Session
}

public struct DefaultRescheduleSessionUseCase: RescheduleSessionUseCase {
    private let repository: any SessionRepository

    public init(repository: any SessionRepository) {
        self.repository = repository
    }

    public func execute(sessionID: UUID, newStart: Date) async throws -> Session {
        let session = try await session(id: sessionID)
        let newTimeRange = try TimeRange(
            start: newStart,
            end: newStart.addingTimeInterval(session.timeRange.end.timeIntervalSince(session.timeRange.start))
        )
        let updated = session.replacing(timeRange: newTimeRange, blocking: true)
        try await repository.updateSession(updated)
        return updated
    }

    private func session(id: UUID) async throws -> Session {
        guard let session = try await repository.fetchSessions().first(where: { $0.id == id }) else {
            throw SchedulingError.entityNotFound(id: id)
        }
        return session
    }
}

public protocol SetSessionLockUseCase: Sendable {
    func execute(sessionID: UUID, isLocked: Bool) async throws -> Session
}

public struct DefaultSetSessionLockUseCase: SetSessionLockUseCase {
    private let repository: any SessionRepository

    public init(repository: any SessionRepository) {
        self.repository = repository
    }

    public func execute(sessionID: UUID, isLocked: Bool) async throws -> Session {
        guard let session = try await repository.fetchSessions().first(where: { $0.id == sessionID }) else {
            throw SchedulingError.entityNotFound(id: sessionID)
        }
        let updated = session.replacing(blocking: isLocked)
        try await repository.updateSession(updated)
        return updated
    }
}

public protocol SetSessionCompletionUseCase: Sendable {
    func execute(sessionID: UUID, isCompleted: Bool) async throws -> Session
}

public struct DefaultSetSessionCompletionUseCase: SetSessionCompletionUseCase {
    private let repository: any SessionRepository

    public init(repository: any SessionRepository) {
        self.repository = repository
    }

    public func execute(sessionID: UUID, isCompleted: Bool) async throws -> Session {
        guard let session = try await repository.fetchSessions().first(where: { $0.id == sessionID }) else {
            throw SchedulingError.entityNotFound(id: sessionID)
        }
        let updated = session.replacing(status: isCompleted ? .completed : .planned)
        try await repository.updateSession(updated)
        return updated
    }
}

public protocol DeleteSessionUseCase: Sendable {
    func execute(sessionID: UUID) async throws
}

public struct DefaultDeleteSessionUseCase: DeleteSessionUseCase {
    private let repository: any SessionRepository

    public init(repository: any SessionRepository) {
        self.repository = repository
    }

    public func execute(sessionID: UUID) async throws {
        guard try await repository.fetchSessions().contains(where: { $0.id == sessionID }) else {
            throw SchedulingError.entityNotFound(id: sessionID)
        }
        try await repository.deleteSession(id: sessionID)
    }
}

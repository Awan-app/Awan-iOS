import Foundation

public struct UpdateSessionScheduleRequest: Equatable, Sendable {
    public let sessionID: UUID
    public let selectedDay: Date
    public let start: Date
    public let end: Date
    public let timeZoneIdentifier: String

    public init(
        sessionID: UUID,
        selectedDay: Date,
        start: Date,
        end: Date,
        timeZoneIdentifier: String
    ) {
        self.sessionID = sessionID
        self.selectedDay = selectedDay
        self.start = start
        self.end = end
        self.timeZoneIdentifier = timeZoneIdentifier
    }
}

public enum SessionScheduleValidationError: Error, Equatable, Sendable {
    case endNotAfterStart
    case outsideSelectedDay
    case invalidTimeZone
}

public enum SessionScheduleValidation: Equatable, Sendable {
    case valid(TimeRange)
    case invalid(SessionScheduleValidationError)

    public var timeRange: TimeRange? {
        guard case let .valid(timeRange) = self else { return nil }
        return timeRange
    }
}

public protocol UpdateSessionScheduleUseCase: Sendable {
    func validate(_ request: UpdateSessionScheduleRequest) -> SessionScheduleValidation
    func execute(_ request: UpdateSessionScheduleRequest) async throws -> Session
}

public struct DefaultUpdateSessionScheduleUseCase: UpdateSessionScheduleUseCase {
    private let repository: any SessionRepository

    public init(repository: any SessionRepository) {
        self.repository = repository
    }

    public func validate(
        _ request: UpdateSessionScheduleRequest
    ) -> SessionScheduleValidation {
        guard request.end > request.start else {
            return .invalid(.endNotAfterStart)
        }

        guard let timeZone = TimeZone(identifier: request.timeZoneIdentifier) else {
            return .invalid(.invalidTimeZone)
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        guard calendar.isDate(request.start, inSameDayAs: request.selectedDay),
              calendar.isDate(request.end, inSameDayAs: request.selectedDay) else {
            return .invalid(.outsideSelectedDay)
        }

        do {
            return .valid(try TimeRange(start: request.start, end: request.end))
        } catch {
            return .invalid(.endNotAfterStart)
        }
    }

    public func execute(
        _ request: UpdateSessionScheduleRequest
    ) async throws -> Session {
        let timeRange: TimeRange
        switch validate(request) {
        case let .valid(validatedRange):
            timeRange = validatedRange
        case let .invalid(error):
            throw error
        }

        guard let session = try await repository.fetchSessions()
            .first(where: { $0.id == request.sessionID }) else {
            throw SchedulingError.entityNotFound(id: request.sessionID)
        }

        let updated = Session(
            id: session.id,
            taskID: session.taskID,
            zoneID: session.zoneID,
            timeRange: timeRange,
            blocking: session.blocking,
            status: session.status,
            firstCompletedAt: session.firstCompletedAt
        )
        try await repository.updateSession(updated)

        return try await repository.fetchSessions()
            .first(where: { $0.id == request.sessionID }) ?? updated
    }
}

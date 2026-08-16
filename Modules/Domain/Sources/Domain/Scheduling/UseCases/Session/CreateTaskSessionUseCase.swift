import Foundation

public struct CreateTaskSessionRequest: Equatable, Sendable {
    public let taskID: UUID
    public let start: Date
    public let end: Date
    public let zoneID: UUID?

    public init(taskID: UUID, start: Date, end: Date, zoneID: UUID? = nil) {
        self.taskID = taskID
        self.start = start
        self.end = end
        self.zoneID = zoneID
    }
}

public protocol CreateTaskSessionUseCase: Sendable {
    func execute(_ request: CreateTaskSessionRequest) async throws -> Session
}

public struct DefaultCreateTaskSessionUseCase: CreateTaskSessionUseCase {
    private let repository: any SessionRepository

    public init(repository: any SessionRepository) {
        self.repository = repository
    }

    public func execute(_ request: CreateTaskSessionRequest) async throws -> Session {
        let timeRange = try TimeRange(start: request.start, end: request.end)
        return try await repository.createSession(
            taskID: request.taskID,
            timeRange: timeRange,
            zoneID: request.zoneID
        )
    }
}

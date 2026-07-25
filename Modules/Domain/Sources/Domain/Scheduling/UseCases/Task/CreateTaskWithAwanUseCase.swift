import Foundation

public struct CreateTaskWithAwanRequest: Equatable, Sendable {
    public let prompt: String
    public let selectedDay: Date
    public let timeZone: TimeZone

    public init(
        prompt: String,
        selectedDay: Date,
        timeZone: TimeZone
    ) {
        self.prompt = prompt
        self.selectedDay = selectedDay
        self.timeZone = timeZone
    }
}

public struct CreateTaskWithAwanResult: Equatable, Sendable {
    public let task: AwanTask
    public let sessions: [Session]

    public init(task: AwanTask, sessions: [Session]) {
        self.task = task
        self.sessions = sessions
    }
}

public protocol CreateTaskWithAwanUseCase: Sendable {
    func execute(
        _ request: CreateTaskWithAwanRequest
    ) async throws -> CreateTaskWithAwanResult?
}

public struct EmptyCreateTaskWithAwanUseCase: CreateTaskWithAwanUseCase {
    public init() {}

    public func execute(
        _ request: CreateTaskWithAwanRequest
    ) async throws -> CreateTaskWithAwanResult? {
        nil
    }
}

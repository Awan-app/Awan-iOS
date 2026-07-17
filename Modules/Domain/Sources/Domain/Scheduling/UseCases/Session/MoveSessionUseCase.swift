public protocol MoveSessionUseCase: Sendable {
    func execute(_ request: MoveSessionRequest) async throws -> ScheduleWorkspace
}

public struct DefaultMoveSessionUseCase: MoveSessionUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let sessionRepository: any SessionRepository

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        sessionRepository: any SessionRepository
    ) {
        self.workspaceProvider = workspaceProvider
        self.sessionRepository = sessionRepository
    }

    public func execute(_ request: MoveSessionRequest) async throws -> ScheduleWorkspace {
        let sessions = try await sessionRepository.fetchSessions()
        guard let session = sessions.first(where: { $0.id == request.sessionID }) else {
            throw SchedulingError.entityNotFound(id: request.sessionID)
        }
        try await sessionRepository.updateSession(
            session.replacing(
                timeRange: request.newTimeRange,
                placement: .userFixed
            )
        )
        return try await workspaceProvider.load()
    }
}

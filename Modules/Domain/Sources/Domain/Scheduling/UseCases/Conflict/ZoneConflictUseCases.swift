import Foundation

public protocol ReplanZoneSessionsUseCase: Sendable {
    func execute(_ request: ReplanZoneSessionsRequest) async throws -> ScheduleOperationResult
}

public struct DefaultReplanZoneSessionsUseCase: ReplanZoneSessionsUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let sessionRepository: any SessionRepository
    private let zoneWindowResolver: any ZoneWindowResolving

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        sessionRepository: any SessionRepository,
        zoneWindowResolver: any ZoneWindowResolving
    ) {
        self.workspaceProvider = workspaceProvider
        self.sessionRepository = sessionRepository
        self.zoneWindowResolver = zoneWindowResolver
    }

    public func execute(
        _ request: ReplanZoneSessionsRequest
    ) async throws -> ScheduleOperationResult {
        let workspace = try await workspaceProvider.load()
        guard let zone = workspace.zones.first(where: { $0.id == request.zoneID }),
              let firstSession = workspace.sessions.first(
                where: { request.sessionIDs.contains($0.id) }
              ) else {
            throw SchedulingError.entityNotFound(id: request.zoneID)
        }
        let window = try zoneWindowResolver.window(
            for: zone,
            on: firstSession.timeRange.start,
            in: request.timeZone
        )
        var cursor = window.start
        for session in workspace.sessions.filter({ request.sessionIDs.contains($0.id) }) {
            let duration = session.timeRange.end.timeIntervalSince(session.timeRange.start)
            let range = try TimeRange(
                start: cursor,
                end: cursor.addingTimeInterval(duration)
            )
            try await sessionRepository.updateSession(
                session.replacing(
                    zoneID: .some(request.zoneID),
                    timeRange: range,
                    placement: .engineManaged
                )
            )
            cursor = range.end
        }
        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(),
            nudge: nil
        )
    }
}

public protocol RestoreZoneUseCase: Sendable {
    func execute(_ zone: Zone) async throws -> ScheduleOperationResult
}

public struct DefaultRestoreZoneUseCase: RestoreZoneUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding
    private let zoneRepository: any ZoneRepository

    public init(
        workspaceProvider: any ScheduleWorkspaceProviding,
        zoneRepository: any ZoneRepository
    ) {
        self.workspaceProvider = workspaceProvider
        self.zoneRepository = zoneRepository
    }

    public func execute(_ zone: Zone) async throws -> ScheduleOperationResult {
        try await zoneRepository.updateZone(zone)
        return ScheduleOperationResult(
            workspace: try await workspaceProvider.load(),
            nudge: nil
        )
    }
}

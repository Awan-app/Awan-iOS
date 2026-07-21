import Foundation

public protocol LoadScheduleWorkspaceUseCase: Sendable {
    func execute(for date: Date) async throws -> ScheduleWorkspace
}

public struct DefaultLoadScheduleWorkspaceUseCase: LoadScheduleWorkspaceUseCase {
    private let workspaceProvider: any ScheduleWorkspaceProviding

    public init(workspaceProvider: any ScheduleWorkspaceProviding) {
        self.workspaceProvider = workspaceProvider
    }

    public func execute(for date: Date) async throws -> ScheduleWorkspace {
        try await workspaceProvider.load(for: date)
    }
}

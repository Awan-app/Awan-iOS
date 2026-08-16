import Domain
import Foundation

public struct DefaultGoalDecompositionRepository: GoalDecompositionRepository {
    private let remoteDataSource: any RemoteGoalDecompositionDataSource
    private let localProfileDataSource: any LocalUserProfileDataSource
    private let localGoalDataSource: any LocalGoalDataSource
    private let localTaskDataSource: any LocalTaskDataSource

    public init(
        remoteDataSource: any RemoteGoalDecompositionDataSource,
        localProfileDataSource: any LocalUserProfileDataSource,
        localGoalDataSource: any LocalGoalDataSource,
        localTaskDataSource: any LocalTaskDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localProfileDataSource = localProfileDataSource
        self.localGoalDataSource = localGoalDataSource
        self.localTaskDataSource = localTaskDataSource
    }

    public func sendMessage(
        _ request: GoalDecompositionRequest
    ) async throws -> GoalDecompositionResponse {
        try await remoteDataSource.sendMessage(
            SendGoalDecompositionMessageRequestDTO(
                sessionID: request.sessionID,
                message: request.message
            )
        )
        .toDomain()
    }

    public func confirmProposal(
        sessionID: UUID
    ) async throws -> ConfirmedGoal {
        let response = try await remoteDataSource.confirmProposal(
            sessionID: sessionID
        )
        let existingGoal = try await localGoalDataSource.fetchGoal(id: response.id)
        let goal = try response.toGoal(
            createdAt: existingGoal?.createdAt ?? Date()
        )
        let tasks = try response.tasks.map { try $0.toTask() }

        if existingGoal == nil {
            try await localGoalDataSource.addGoal(goal)
        } else {
            try await localGoalDataSource.updateGoal(goal)
        }
        try await localTaskDataSource.upsertTasks(tasks)

        return ConfirmedGoal(
            id: response.id,
            title: response.title,
            tasks: response.tasks.map {
                ConfirmedGoalTask(
                    id: $0.id,
                    title: $0.title,
                    estimatedDuration: $0.estimatedDuration
                )
            }
        )
    }

    public func requestScheduleProposal(
        goalID: UUID
    ) async throws -> GoalScheduleProposal {
        let response = try await remoteDataSource.requestSchedule(
            ScheduleGoalRequestDTO(goalID: goalID)
        )
        return try response.toDomain(timeZoneID: await timeZoneID())
    }

    public func confirmSchedule(
        goalID: UUID,
        sessions: [GoalScheduleConfirmationItem]
    ) async throws -> [ConfirmedGoalScheduleSession] {
        let timeZoneID = await timeZoneID()
        let response = try await remoteDataSource.confirmSchedule(
            ConfirmGoalScheduleRequestDTO(
                goalID: goalID,
                sessions: sessions.map {
                    ConfirmGoalScheduleSessionDTO(
                        taskID: $0.taskID,
                        zoneID: $0.zoneID,
                        start: GoalScheduleDateMapper.string(
                            from: $0.start,
                            timeZoneID: timeZoneID
                        ),
                        end: GoalScheduleDateMapper.string(
                            from: $0.end,
                            timeZoneID: timeZoneID
                        )
                    )
                }
            )
        )
        return try response.map { try $0.toDomain(timeZoneID: timeZoneID) }
    }

    private func timeZoneID() async -> String {
        (try? await localProfileDataSource.fetchProfile())?
            .preferences.timezone ?? TimeZone.current.identifier
    }
}

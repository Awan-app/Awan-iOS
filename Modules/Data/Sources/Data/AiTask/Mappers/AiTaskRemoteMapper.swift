//
//  AiTaskRemoteMapper.swift
//  Data
//

import Domain
import Foundation

extension CreateAiTaskResponseDTO {
    func toDomain(timeZoneID: String) throws -> [AITaskSheetItem] {
        try tasks.map { taskDTO in
            let taskPayload = taskDTO.draft.task
            let mappedTask = AwanTask(
                id: UUID(),
                title: taskPayload.title,
                description: taskPayload.description,
                status: taskDTO.aiProposedSessions.isEmpty ? .drafted : .active,
                goalID: taskPayload.goalId,
                duration: try! TaskDuration(minutes: max(1, taskPayload.estimatedDuration ?? 60)),
                isSplittable: taskPayload.allowTaskSplitting ?? false,
                mandatory: taskPayload.mandatory ?? false,
                estimatedPoints: taskPayload.estimatedPoints ?? 0,
                dependencyIDs: [],
                category: taskPayload.categoryId.map { TaskCategory(id: $0, name: "") }
            )
            let mappedSessions = try taskDTO.aiProposedSessions.map { dto in
                try dto.toDomain(timeZoneID: timeZoneID)
            }
            let startTime = mappedSessions.first?.timeRange.start ?? Date()
            return AITaskSheetItem(
                task: mappedTask,
                startTime: startTime,
                sessions: mappedSessions,
                reason: taskDTO.reason
            )
        }
    }
}

extension CreateAiTaskResponseDTO.AiProposedSessionDTO {
    func toDomain(timeZoneID: String) throws -> AiProposedSession {
        AiProposedSession(
            zoneID: zoneId,
            timeRange: try TimeRange(
                start: try parseDateTime(start, timeZoneID: timeZoneID),
                end: try parseDateTime(end, timeZoneID: timeZoneID)
            ),
            status: status
        )
    }
}

private extension CategoryResponseDTO {
    func toDomain() -> TaskCategory {
        TaskCategory(id: id, name: name)
    }
}

// MARK: - Private Helpers

private extension CreateAiTaskResponseDTO.AiProposedSessionDTO {
    func parseDateTime(_ value: String, timeZoneID: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: timeZoneID) ?? .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let date = formatter.date(from: value) else {
            throw URLError(.cannotParseResponse)
        }
        return date
    }
}

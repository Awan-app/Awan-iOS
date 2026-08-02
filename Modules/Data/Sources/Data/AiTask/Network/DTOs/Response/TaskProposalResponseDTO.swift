//
//  TaskProposalResponseDTO.swift
//  Data
//

import Domain
import Foundation

public struct TaskProposalResponseDTO: Decodable, Sendable {
    public let sourceSummary: String?
    public let tasks: [ProposedTaskDTO]
    public let timestamp: String?

    public func toDomain() -> TaskProposalResponse {
        let parsedTimestamp: Date
        if let timestampStr = timestamp, let date = ISO8601Helper.parse(timestampStr) {
            parsedTimestamp = date
        } else {
            parsedTimestamp = Date()
        }

        return TaskProposalResponse(
            sourceSummary: sourceSummary,
            tasks: tasks.map { $0.toDomain() },
            timestamp: parsedTimestamp
        )
    }
}

public struct ProposedTaskDTO: Decodable, Sendable {
    public let draft: TaskWithSessionsDraftDTO
    public let aiProposedSessions: [ProposedSessionDTO]?
    public let reason: String?

    public func toDomain() -> ProposedTask {
        ProposedTask(
            draft: draft.toDomain(),
            aiProposedSessions: (aiProposedSessions ?? []).map { $0.toDomain() },
            reason: reason ?? ""
        )
    }
}

public struct TaskWithSessionsDraftDTO: Codable, Sendable {
    public let task: ProposedTaskDetailsDTO
    public let sessions: [ProposedSessionDTO]?

    public func toDomain() -> TaskWithSessionsDraft {
        TaskWithSessionsDraft(
            task: task.toDomain(),
            sessions: (sessions ?? []).map { $0.toDomain() }
        )
    }

    public init(domain: TaskWithSessionsDraft) {
        self.task = ProposedTaskDetailsDTO(domain: domain.task)
        self.sessions = domain.sessions.map { ProposedSessionDTO(domain: $0) }
    }
}

public struct ProposedTaskDetailsDTO: Codable, Sendable {
    public let title: String
    public let description: String?
    public let estimatedDuration: Int?
    public let mandatory: Bool?
    public let estimatedPoints: Int?
    public let allowTaskSplitting: Bool?
    public let goalId: UUID?
    public let categoryId: UUID?

    private enum CodingKeys: String, CodingKey {
        case title
        case description
        case estimatedDuration
        case mandatory
        case estimatedPoints
        case allowTaskSplitting
        case goalId
        case categoryId
    }

    public func toDomain() -> ProposedTaskDetails {
        ProposedTaskDetails(
            title: title,
            description: description,
            estimatedDuration: estimatedDuration ?? 60,
            mandatory: mandatory ?? true,
            estimatedPoints: estimatedPoints ?? 10,
            allowTaskSplitting: allowTaskSplitting ?? false,
            goalId: goalId,
            categoryId: categoryId
        )
    }

    public init(domain: ProposedTaskDetails) {
        self.title = domain.title
        self.description = domain.description
        self.estimatedDuration = domain.estimatedDuration
        self.mandatory = domain.mandatory
        self.estimatedPoints = domain.estimatedPoints
        self.allowTaskSplitting = domain.allowTaskSplitting
        self.goalId = domain.goalId
        self.categoryId = domain.categoryId
    }
}

public struct ProposedSessionDTO: Codable, Sendable {
    public let zoneId: UUID?
    public let start: String
    public let end: String
    public let status: String?

    public func toDomain() -> ProposedSession {
        let startDate = ISO8601Helper.parse(start) ?? Date()
        let endDate = ISO8601Helper.parse(end) ?? startDate.addingTimeInterval(3600)

        return ProposedSession(
            zoneId: zoneId,
            start: startDate,
            end: endDate,
            status: status ?? "SCHEDULED"
        )
    }

    public init(domain: ProposedSession) {
        self.zoneId = domain.zoneId
        self.start = ISO8601Helper.string(from: domain.start)
        self.end = ISO8601Helper.string(from: domain.end)
        self.status = domain.status
    }
}

private enum ISO8601Helper {
    static func parse(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: string) {
            return date
        }
        let localFormatter = DateFormatter()
        localFormatter.calendar = Calendar(identifier: .gregorian)
        localFormatter.locale = Locale(identifier: "en_US_POSIX")
        localFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return localFormatter.date(from: string)
    }

    static func string(from date: Date) -> String {
        let localFormatter = DateFormatter()
        localFormatter.calendar = Calendar(identifier: .gregorian)
        localFormatter.locale = Locale(identifier: "en_US_POSIX")
        localFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return localFormatter.string(from: date)
    }
}

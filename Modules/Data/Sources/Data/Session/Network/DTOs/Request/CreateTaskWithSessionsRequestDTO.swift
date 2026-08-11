//
//  CreateTaskWithSessionsRequestDTO.swift
//  Data
//
//  Created by JETSMobileLabMini8 on 21/07/2026.
//

import Domain
import Foundation

public struct CreateTaskWithSessionsRequestDTO: Encodable, Sendable {
    public let task: TaskPayload
    public let sessions: [SessionPayload]?

    public init(task: TaskPayload, sessions: [SessionPayload]? = nil) {
        self.task = task
        self.sessions = sessions
    }

    public init(draft: TaskWithSessionsDraft) {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        self.task = TaskPayload(
            title: draft.task.title,
            description: draft.task.description,
            estimatedDuration: draft.task.estimatedDuration,
            mandatory: draft.task.mandatory,
            estimatedPoints: draft.task.estimatedPoints,
            allowTaskSplitting: draft.task.allowTaskSplitting,
            goalId: draft.task.goalId,
            categoryId: draft.task.categoryId
        )
        self.sessions = draft.sessions.map { session in
            SessionPayload(
                zoneId: session.zoneId,
                start: formatter.string(from: session.start),
                end: formatter.string(from: session.end),
                status: session.status
            )
        }
    }

    public struct TaskPayload: Encodable, Sendable {
        public let title: String
        public let description: String?
        public let estimatedDuration: Int?
        public let mandatory: Bool?
        public let estimatedPoints: Int?
        public let allowTaskSplitting: Bool?
        public let goalId: UUID?
        public let categoryId: UUID?

        public init(
            title: String,
            description: String? = nil,
            estimatedDuration: Int? = nil,
            mandatory: Bool? = nil,
            estimatedPoints: Int? = nil,
            allowTaskSplitting: Bool? = nil,
            goalId: UUID? = nil,
            categoryId: UUID? = nil
        ) {
            self.title = title
            self.description = description
            self.estimatedDuration = estimatedDuration
            self.mandatory = mandatory
            self.estimatedPoints = estimatedPoints
            self.allowTaskSplitting = allowTaskSplitting
            self.goalId = goalId
            self.categoryId = categoryId
        }

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

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encodeIfPresent(description, forKey: .description)
            try container.encodeIfPresent(estimatedDuration, forKey: .estimatedDuration)
            try container.encodeIfPresent(mandatory, forKey: .mandatory)
            try container.encodeIfPresent(estimatedPoints, forKey: .estimatedPoints)
            try container.encodeIfPresent(allowTaskSplitting, forKey: .allowTaskSplitting)
            try container.encodeIfPresent(goalId, forKey: .goalId)
            try container.encodeIfPresent(categoryId, forKey: .categoryId)
        }
    }

    public struct SessionPayload: Encodable, Sendable {
        public let zoneId: UUID?
        public let start: String
        public let end: String
        public let status: String?

        public init(
            zoneId: UUID? = nil,
            start: String,
            end: String,
            status: String? = nil
        ) {
            self.zoneId = zoneId
            self.start = start
            self.end = end
            self.status = status
        }

        private enum CodingKeys: String, CodingKey {
            case zoneId
            case start
            case end
            case status
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(zoneId, forKey: .zoneId)
            try container.encode(start, forKey: .start)
            try container.encode(end, forKey: .end)
            try container.encodeIfPresent(status, forKey: .status)
        }
    }
}

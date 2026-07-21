//
//  CreateTaskWithSessionsRequestDTO.swift
//  Data
//
//  Created by JETSMobileLabMini8 on 21/07/2026.
//

import Foundation

public struct CreateTaskWithSessionsRequestDTO: Encodable, Sendable {
    public let task: TaskPayload
    public let sessions: [SessionPayload]?

    public init(task: TaskPayload, sessions: [SessionPayload]? = nil) {
        self.task = task
        self.sessions = sessions
    }

    public struct TaskPayload: Encodable, Sendable {
        public let title: String
        public let description: String?
        public let estimatedDuration: Int?
        public let mandatory: Bool?
        public let estimatedPoints: Int?
        public let allowTaskSplitting: Bool?
        public let goalId: UUID?

        public init(
            title: String,
            description: String? = nil,
            estimatedDuration: Int? = nil,
            mandatory: Bool? = nil,
            estimatedPoints: Int? = nil,
            allowTaskSplitting: Bool? = nil,
            goalId: UUID? = nil
        ) {
            self.title = title
            self.description = description
            self.estimatedDuration = estimatedDuration
            self.mandatory = mandatory
            self.estimatedPoints = estimatedPoints
            self.allowTaskSplitting = allowTaskSplitting
            self.goalId = goalId
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
    }
}

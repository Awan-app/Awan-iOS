//
//  CreateAiTaskResponseDTO.swift
//  Data
//

import Foundation

public struct CreateAiTaskResponseDTO: Decodable, Sendable {
    public let sourceSummary: String?
    public let tasks: [AiTaskResultDTO]
    public let timestamp: String?

    public init(sourceSummary: String?, tasks: [AiTaskResultDTO], timestamp: String?) {
        self.sourceSummary = sourceSummary
        self.tasks = tasks
        self.timestamp = timestamp
    }

    public struct AiTaskResultDTO: Decodable, Sendable {
        public let draft: AiTaskDraftDTO
        public let aiProposedSessions: [AiProposedSessionDTO]
        public let reason: String?

        public init(draft: AiTaskDraftDTO, aiProposedSessions: [AiProposedSessionDTO], reason: String?) {
            self.draft = draft
            self.aiProposedSessions = aiProposedSessions
            self.reason = reason
        }
    }

    public struct AiTaskDraftDTO: Decodable, Sendable {
        public let task: AiTaskPayloadDTO
        public let sessions: [AiProposedSessionDTO]

        public init(task: AiTaskPayloadDTO, sessions: [AiProposedSessionDTO]) {
            self.task = task
            self.sessions = sessions
        }
    }

    public struct AiProposedSessionDTO: Decodable, Sendable {
        public let start: String
        public let end: String
        public let status: String
        public let zoneId: UUID?

        private enum CodingKeys: String, CodingKey {
            case start
            case end
            case status
            case zoneId
        }

        public init(
            start: String,
            end: String,
            status: String,
            zoneId: UUID? = nil,
        ) {
            self.start = start
            self.end = end
            self.status = status
            self.zoneId = zoneId
        }
    }

    public struct AiTaskPayloadDTO: Decodable, Sendable {
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

        public init(
            title: String,
            description: String?,
            estimatedDuration: Int?,
            mandatory: Bool?,
            estimatedPoints: Int?,
            allowTaskSplitting: Bool?,
            goalId: UUID?,
            categoryId: UUID?
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
    }
}

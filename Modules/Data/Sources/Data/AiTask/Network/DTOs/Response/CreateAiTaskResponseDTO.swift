//
//  CreateAiTaskResponseDTO.swift
//  Data
//

import Foundation

public struct CreateAiTaskResponseDTO: Decodable, Sendable {
    public let task: AiTaskPayloadDTO
    public let sessions: [SessionResponseDTO]

    public init(task: AiTaskPayloadDTO, sessions: [SessionResponseDTO]) {
        self.task = task
        self.sessions = sessions
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

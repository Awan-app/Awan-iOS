import Foundation

public struct GoalDecompositionResponseDTO: Decodable, Sendable {
    public let sessionID: UUID
    public let blocks: [GoalDecompositionBlockDTO]
    public let hasProposal: Bool

    private enum CodingKeys: String, CodingKey {
        case sessionID = "sessionId"
        case blocks
        case hasProposal
    }
}

public enum GoalDecompositionBlockDTO: Decodable, Sendable {
    case text(TextBlockDTO)
    case question(QuestionBlockDTO)
    case proposal(GoalProposalBlockDTO)

    private enum CodingKeys: String, CodingKey {
        case type
    }

    private enum BlockType: String, Decodable {
        case text
        case question
        case proposal
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(BlockType.self, forKey: .type) {
        case .text:
            self = .text(try TextBlockDTO(from: decoder))
        case .question:
            self = .question(try QuestionBlockDTO(from: decoder))
        case .proposal:
            self = .proposal(try GoalProposalBlockDTO(from: decoder))
        }
    }
}

public struct TextBlockDTO: Decodable, Sendable {
    public let text: String
}

public struct QuestionBlockDTO: Decodable, Sendable {
    public let text: String
    public let options: [String]
}

public struct GoalProposalBlockDTO: Decodable, Sendable {
    public let proposal: GoalProposalDTO
}

public struct GoalProposalDTO: Decodable, Sendable {
    public let title: String
    public let description: String
    public let targetDate: String?
    public let tasks: [GoalTaskProposalDTO]
}

public struct GoalTaskProposalDTO: Decodable, Sendable {
    public let tempID: String
    public let title: String
    public let description: String
    public let estimatedDuration: Int
    public let estimatedPoints: Int
    public let mandatory: Bool
    public let allowsTaskSplitting: Bool
    public let dependencyIDs: [String]
    public let category: GoalProposalCategoryDTO?

    private enum CodingKeys: String, CodingKey {
        case tempID = "tempId"
        case title
        case description
        case estimatedDuration
        case estimatedPoints
        case mandatory
        case allowsTaskSplitting = "allowTaskSplitting"
        case dependencyIDs = "dependsOnTempIds"
        case category
    }
}

public struct GoalProposalCategoryDTO: Decodable, Sendable {
    public let id: UUID
    public let name: String
}

public struct ConfirmedGoalResponseDTO: Decodable, Sendable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let targetDate: String?
    public let status: String
    public let tasks: [ConfirmedGoalTaskResponseDTO]
}

public struct ConfirmedGoalTaskResponseDTO: Decodable, Sendable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let status: String
    public let estimatedDuration: Int
    public let estimatedPoints: Int
    public let mandatory: Bool
    public let allowsTaskSplitting: Bool
    public let goalID: UUID
    public let dependencyIDs: [UUID]
    public let category: GoalProposalCategoryDTO?

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case status
        case estimatedDuration
        case estimatedPoints
        case mandatory
        case allowsTaskSplitting = "allowTaskSplitting"
        case goalID = "goalId"
        case dependencyIDs = "dependsOnTaskIds"
        case category
    }
}

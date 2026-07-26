import Foundation

public struct GoalDecompositionRequest: Equatable, Sendable {
    public let sessionID: UUID?
    public let message: String

    public init(sessionID: UUID?, message: String) {
        self.sessionID = sessionID
        self.message = message
    }
}

public struct GoalDecompositionResponse: Equatable, Sendable {
    public let sessionID: UUID
    public let blocks: [GoalDecompositionBlock]
    public let hasProposal: Bool

    public init(
        sessionID: UUID,
        blocks: [GoalDecompositionBlock],
        hasProposal: Bool
    ) {
        self.sessionID = sessionID
        self.blocks = blocks
        self.hasProposal = hasProposal
    }
}

public enum GoalDecompositionBlock: Equatable, Sendable {
    case text(String)
    case question(GoalDecompositionQuestion)
    case proposal(GoalProposal)
}

public struct GoalDecompositionQuestion: Equatable, Sendable {
    public let text: String
    public let options: [String]

    public init(text: String, options: [String]) {
        self.text = text
        self.options = options
    }
}

public struct GoalProposal: Equatable, Sendable {
    public let title: String
    public let description: String
    public let targetDate: Date?
    public let tasks: [GoalTaskProposal]

    public init(
        title: String,
        description: String,
        targetDate: Date?,
        tasks: [GoalTaskProposal]
    ) {
        self.title = title
        self.description = description
        self.targetDate = targetDate
        self.tasks = tasks
    }
}

public struct GoalTaskProposal: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let estimatedDuration: Int
    public let estimatedPoints: Int
    public let mandatory: Bool
    public let allowsTaskSplitting: Bool
    public let dependencyIDs: [String]
    public let category: GoalProposalCategory?

    public init(
        id: String,
        title: String,
        description: String,
        estimatedDuration: Int,
        estimatedPoints: Int,
        mandatory: Bool,
        allowsTaskSplitting: Bool,
        dependencyIDs: [String],
        category: GoalProposalCategory?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.estimatedDuration = estimatedDuration
        self.estimatedPoints = estimatedPoints
        self.mandatory = mandatory
        self.allowsTaskSplitting = allowsTaskSplitting
        self.dependencyIDs = dependencyIDs
        self.category = category
    }
}

public struct GoalProposalCategory: Equatable, Sendable {
    public let id: UUID
    public let name: String

    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}

public struct ConfirmedGoal: Equatable, Sendable {
    public let id: UUID
    public let title: String

    public init(id: UUID, title: String) {
        self.id = id
        self.title = title
    }
}

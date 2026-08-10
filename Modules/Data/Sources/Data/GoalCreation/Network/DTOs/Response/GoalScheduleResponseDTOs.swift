import Foundation

public struct GoalScheduleProposalResponseDTO: Decodable, Sendable {
    public let goalID: UUID
    public let proposedSessions: [GoalScheduleSessionResponseDTO]
    public let suggestions: [GoalScheduleSuggestionResponseDTO]
    public let unscheduledTasks: [GoalScheduleUnscheduledTaskResponseDTO]

    private enum CodingKeys: String, CodingKey {
        case goalID = "goalId"
        case proposedSessions
        case suggestions
        case unscheduledTasks
    }
}

public struct GoalScheduleSessionResponseDTO: Decodable, Sendable {
    public let taskID: UUID
    public let taskTitle: String
    public let zoneID: UUID?
    public let start: String
    public let end: String

    private enum CodingKeys: String, CodingKey {
        case taskID = "taskId"
        case taskTitle
        case zoneID = "zoneId"
        case start
        case end
    }
}

public struct GoalScheduleSuggestionResponseDTO: Decodable, Sendable {
    public let taskID: UUID
    public let taskTitle: String
    public let zoneID: UUID?
    public let start: String
    public let end: String
    public let suggestionType: String
    public let reason: String
    public let overlapInfo: GoalScheduleOverlapInfoResponseDTO?

    private enum CodingKeys: String, CodingKey {
        case taskID = "taskId"
        case taskTitle
        case zoneID = "zoneId"
        case start
        case end
        case suggestionType
        case reason
        case overlapInfo
    }
}

public struct GoalScheduleOverlapInfoResponseDTO: Decodable, Sendable {
    public let taskTitle: String
    public let start: String
    public let end: String
    public let mandatory: Bool
    public let points: Int
}

public struct GoalScheduleUnscheduledTaskResponseDTO: Decodable, Sendable {
    public let taskID: UUID
    public let taskTitle: String
    public let message: String

    private enum CodingKeys: String, CodingKey {
        case taskID = "taskId"
        case taskTitle
        case message
    }
}

public struct ConfirmedGoalScheduleSessionResponseDTO: Decodable, Sendable {
    public let id: UUID
    public let taskID: UUID
    public let zoneID: UUID?
    public let start: String
    public let end: String

    private enum CodingKeys: String, CodingKey {
        case id
        case sessionID = "sessionId"
        case taskID = "taskId"
        case zoneID = "zoneId"
        case start
        case end
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let id = try container.decodeIfPresent(UUID.self, forKey: .id) {
            self.id = id
        } else {
            self.id = try container.decode(UUID.self, forKey: .sessionID)
        }
        taskID = try container.decode(UUID.self, forKey: .taskID)
        zoneID = try container.decodeIfPresent(UUID.self, forKey: .zoneID)
        start = try container.decode(String.self, forKey: .start)
        end = try container.decode(String.self, forKey: .end)
    }
}

import Foundation

public struct SendGoalDecompositionMessageRequestDTO: Encodable, Sendable {
    public let sessionID: UUID?
    public let message: String

    private enum CodingKeys: String, CodingKey {
        case sessionID = "sessionId"
        case message
    }

    public init(sessionID: UUID?, message: String) {
        self.sessionID = sessionID
        self.message = message
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let sessionID {
            try container.encode(sessionID, forKey: .sessionID)
        } else {
            try container.encodeNil(forKey: .sessionID)
        }
        try container.encode(message, forKey: .message)
    }
}

public struct ScheduleGoalRequestDTO: Encodable, Sendable {
    public let goalID: UUID

    private enum CodingKeys: String, CodingKey {
        case goalID = "goalId"
    }

    public init(goalID: UUID) {
        self.goalID = goalID
    }
}

public struct ConfirmGoalScheduleRequestDTO: Encodable, Sendable {
    public let goalID: UUID
    public let sessions: [ConfirmGoalScheduleSessionDTO]

    private enum CodingKeys: String, CodingKey {
        case goalID = "goalId"
        case sessions
    }

    public init(goalID: UUID, sessions: [ConfirmGoalScheduleSessionDTO]) {
        self.goalID = goalID
        self.sessions = sessions
    }
}

public struct ConfirmGoalScheduleSessionDTO: Encodable, Sendable {
    public let taskID: UUID
    public let zoneID: UUID?
    public let start: String
    public let end: String

    private enum CodingKeys: String, CodingKey {
        case taskID = "taskId"
        case zoneID = "zoneId"
        case start
        case end
    }

    public init(taskID: UUID, zoneID: UUID?, start: String, end: String) {
        self.taskID = taskID
        self.zoneID = zoneID
        self.start = start
        self.end = end
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(taskID, forKey: .taskID)
        try container.encode(zoneID, forKey: .zoneID)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
    }
}

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

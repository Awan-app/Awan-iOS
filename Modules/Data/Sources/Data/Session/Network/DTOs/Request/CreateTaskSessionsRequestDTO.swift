public struct CreateTaskSessionsRequestDTO: Encodable, Sendable {
    public let sessions: [CreateTaskWithSessionsRequestDTO.SessionPayload]

    public init(sessions: [CreateTaskWithSessionsRequestDTO.SessionPayload]) {
        self.sessions = sessions
    }
}

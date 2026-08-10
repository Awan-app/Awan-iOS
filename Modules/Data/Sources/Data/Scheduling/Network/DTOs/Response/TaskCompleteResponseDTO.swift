public struct TaskCompleteResponseDTO: Decodable, Sendable {
    public let task: TaskInfoResponseDTO
    public let completedSessions: [SessionResponseDTO]
    public let reward: CompletionRewardDTO
}

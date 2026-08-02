public struct TasksWithSessionsResponseDTO: Decodable, Sendable {
    public let tasks: [TaskWithSessionsResponseDTO]

    public init(tasks: [TaskWithSessionsResponseDTO]) {
        self.tasks = tasks
    }
}

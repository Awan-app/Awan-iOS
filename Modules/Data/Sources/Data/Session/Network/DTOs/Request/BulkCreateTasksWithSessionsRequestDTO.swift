import Domain

public struct BulkCreateTasksWithSessionsRequestDTO: Encodable, Sendable {
    public let tasks: [CreateTaskWithSessionsRequestDTO]

    public init(drafts: [TaskWithSessionsDraft]) {
        self.tasks = drafts.map(CreateTaskWithSessionsRequestDTO.init(draft:))
    }
}

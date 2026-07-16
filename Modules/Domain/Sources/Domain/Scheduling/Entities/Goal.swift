import Foundation

public struct Goal: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let deadline: Date

    public init(id: UUID, name: String, deadline: Date) {
        self.id = id
        self.name = name
        self.deadline = deadline
    }
}

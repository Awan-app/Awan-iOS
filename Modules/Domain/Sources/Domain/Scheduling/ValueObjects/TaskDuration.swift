public struct TaskDuration: Hashable, Sendable {
    public let minutes: Int

    public init(minutes: Int) throws {
        guard minutes > 0 else {
            throw SchedulingError.invalidDuration(minutes: minutes)
        }

        self.minutes = minutes
    }
}

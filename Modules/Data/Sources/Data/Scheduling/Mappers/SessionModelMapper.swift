import Domain

extension SessionModel {
    func toDomain() throws -> Session {
        let status: Session.Status
        switch statusRaw {
        case "planned": status = .planned
        case "completed": status = .completed
        case "missed": status = .missed
        case "cancelled": status = .cancelled
        default: throw SchedulingError.invalidSessionStatus(raw: statusRaw)
        }
        return Session(
            id: id,
            taskID: taskID,
            zoneID: zoneID,
            timeRange: try TimeRange(start: startDate, end: endDate),
            blocking: blocking,
            status: status
        )
    }

    convenience init(domain session: Session) {
        self.init(
            id: session.id,
            taskID: session.taskID,
            zoneID: session.zoneID,
            startDate: session.timeRange.start,
            endDate: session.timeRange.end,
            blocking: session.blocking,
            statusRaw: Self.rawValue(for: session.status)
        )
    }

    func update(from session: Session) {
        taskID = session.taskID
        zoneID = session.zoneID
        startDate = session.timeRange.start
        endDate = session.timeRange.end
        blocking = session.blocking
        statusRaw = Self.rawValue(for: session.status)
    }

    private static func rawValue(for status: Session.Status) -> String {
        switch status {
        case .planned: "planned"
        case .completed: "completed"
        case .missed: "missed"
        case .cancelled: "cancelled"
        }
    }
}

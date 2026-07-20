import Domain
import Foundation

extension SessionRecord {
    func toDomain() throws -> Session {
        return Session(
            id: id,
            taskID: taskID,
            zoneID: zoneID,
            timeRange: timeRange,
            blocking: blocking,
            status: status
        )
    }

    init(domain session: Session) {
        self.init(
            id: session.id,
            taskID: session.taskID,
            zoneID: session.zoneID,
            timeRange: session.timeRange,
            blocking: session.blocking,
            status: session.status
        )
    }
}

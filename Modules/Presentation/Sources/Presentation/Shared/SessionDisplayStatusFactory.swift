import Domain
import Foundation

public enum SessionDisplayStatus: Hashable, Sendable {
    case scheduled
    case activeNow
    case missed
    case completed
    case cancelled
}

public struct SessionDisplayStatusFactory: Sendable {
    public init() {}

    public func make(
        session: Session,
        now: Date = Date()
    ) -> SessionDisplayStatus {
        switch session.status {
        case .completed:
            .completed
        case .cancelled:
            .cancelled
        case .missed:
            .missed
        case .planned:
            if now >= session.timeRange.start && now <= session.timeRange.end {
                .activeNow
            } else if now > session.timeRange.end {
                .missed
            } else {
                .scheduled
            }
        }
    }
}

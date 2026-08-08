import Foundation

public enum WakeSleepTimeValidation: Equatable, Sendable {
    case valid(durationMinutes: Int)
    case sameTime
    case sleepBeforeWake
}

public struct WakeSleepTimeValidator: Sendable {
    public init() {}

    public func validate(
        wakeupTime: LocalTime,
        sleepTime: LocalTime
    ) -> WakeSleepTimeValidation {
        if sleepTime == wakeupTime {
            return .sameTime
        }

        guard sleepTime > wakeupTime else {
            return .sleepBeforeWake
        }

        return .valid(
            durationMinutes: sleepTime.minutesSinceMidnight
                - wakeupTime.minutesSinceMidnight
        )
    }
}

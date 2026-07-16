import Foundation

public protocol ZoneWindowResolving: Sendable {
    func window(for zone: Zone, on day: Date, in timeZone: TimeZone) throws -> TimeRange
}

public struct CalendarZoneWindowResolver: ZoneWindowResolving {
    public init() {}

    public func window(for zone: Zone, on day: Date, in timeZone: TimeZone) throws -> TimeRange {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        let dayComponents = calendar.dateComponents([.year, .month, .day], from: day)
        var startComponents = dayComponents
        startComponents.hour = zone.startTime.hour
        startComponents.minute = zone.startTime.minute

        guard let start = calendar.date(from: startComponents) else {
            throw SchedulingError.invalidTimeRange
        }

        var endComponents = dayComponents
        endComponents.hour = zone.endTime.hour
        endComponents.minute = zone.endTime.minute

        guard var end = calendar.date(from: endComponents) else {
            throw SchedulingError.invalidTimeRange
        }

        if zone.endTime <= zone.startTime {
            guard let nextDayEnd = calendar.date(byAdding: .day, value: 1, to: end) else {
                throw SchedulingError.invalidTimeRange
            }
            end = nextDayEnd
        }

        return try TimeRange(start: start, end: end)
    }
}

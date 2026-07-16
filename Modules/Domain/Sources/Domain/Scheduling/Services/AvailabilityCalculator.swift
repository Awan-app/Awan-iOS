import Foundation

public protocol AvailabilityCalculating: Sendable {
    func freeRanges(
        inside window: TimeRange,
        excluding occupiedRanges: [TimeRange],
        notBefore earliestStart: Date?
    ) throws -> [TimeRange]
}

public struct DefaultAvailabilityCalculator: AvailabilityCalculating {
    public init() {}

    public func freeRanges(
        inside window: TimeRange,
        excluding occupiedRanges: [TimeRange],
        notBefore earliestStart: Date?
    ) throws -> [TimeRange] {
        let effectiveStart = max(window.start, earliestStart ?? window.start)
        guard effectiveStart < window.end else { return [] }

        var relevant: [(start: Date, end: Date)] = []
        for range in occupiedRanges where range.end > effectiveStart && range.start < window.end {
            relevant.append(
                (start: max(range.start, effectiveStart), end: min(range.end, window.end))
            )
        }
        relevant.sort {
            $0.start == $1.start ? $0.end < $1.end : $0.start < $1.start
        }

        var merged: [(start: Date, end: Date)] = []
        for range in relevant {
            if let last = merged.last, range.start <= last.end {
                merged[merged.count - 1].end = max(last.end, range.end)
            } else {
                merged.append(range)
            }
        }

        var free: [TimeRange] = []
        var cursor = effectiveStart

        for range in merged {
            if cursor < range.start {
                free.append(try TimeRange(start: cursor, end: range.start))
            }
            cursor = max(cursor, range.end)
        }

        if cursor < window.end {
            free.append(try TimeRange(start: cursor, end: window.end))
        }

        return free
    }
}

//
//  WakeSleepScheduleValidator.swift
//  Common
//

import Foundation

public struct WakeSleepScheduleValidator {
    /// Calculates total available active hours between wake and sleep times.
    public static func availableHours(wakeupTime: Date, sleepTime: Date, calendar: Calendar = .current) -> Int {
        let wakeComponents = calendar.dateComponents([.hour, .minute], from: wakeupTime)
        let sleepComponents = calendar.dateComponents([.hour, .minute], from: sleepTime)

        let wakeMinutes = (wakeComponents.hour ?? 7) * 60 + (wakeComponents.minute ?? 0)
        var sleepMinutes = (sleepComponents.hour ?? 23) * 60 + (sleepComponents.minute ?? 0)

        if sleepMinutes <= wakeMinutes {
            sleepMinutes += 24 * 60
        }

        return (sleepMinutes - wakeMinutes) / 60
    }

    /// Returns `true` when wakeup and sleep represent the exact same hour and minute.
    public static func areTimesEqual(wakeupTime: Date, sleepTime: Date, calendar: Calendar = .current) -> Bool {
        let wakeHM = calendar.dateComponents([.hour, .minute], from: wakeupTime)
        let sleepHM = calendar.dateComponents([.hour, .minute], from: sleepTime)
        return wakeHM.hour == sleepHM.hour && wakeHM.minute == sleepHM.minute
    }

    /// Returns `true` when active day is shorter than 9 hours.
    public static func isShortActiveDay(wakeupTime: Date, sleepTime: Date, calendar: Calendar = .current) -> Bool {
        !areTimesEqual(wakeupTime: wakeupTime, sleepTime: sleepTime, calendar: calendar) &&
        availableHours(wakeupTime: wakeupTime, sleepTime: sleepTime, calendar: calendar) < 9
    }

    /// Returns `true` if schedule is valid (times not equal and active hours >= 9).
    public static func isValid(wakeupTime: Date, sleepTime: Date, calendar: Calendar = .current) -> Bool {
        !areTimesEqual(wakeupTime: wakeupTime, sleepTime: sleepTime, calendar: calendar) &&
        availableHours(wakeupTime: wakeupTime, sleepTime: sleepTime, calendar: calendar) >= 9
    }
}

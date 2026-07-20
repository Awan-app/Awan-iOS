//
//  UpdateSleepScheduleRequestDTO.swift
//  Data
//

import Foundation

public struct UpdateSleepScheduleRequestDTO: Encodable, Sendable {
    public let wakeupTime: String
    public let sleepTime: String

    public init(wakeupTime: String, sleepTime: String) {
        self.wakeupTime = wakeupTime
        self.sleepTime = sleepTime
    }
}

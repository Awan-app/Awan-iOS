//
//  UpdateSchedulingTypeRequestDTO.swift
//  Data
//

import Foundation

public struct UpdateSchedulingTypeRequestDTO: Encodable, Sendable {
    public let schedulingType: String

    public init(schedulingType: String) {
        self.schedulingType = schedulingType
    }
}

//
//  UpdateGoalRequestDTO.swift
//  Data
//

import Foundation

public struct UpdateGoalRequestDTO: Encodable, Sendable {
    public let title: String?
    public let description: String?
    public let status: String?
    public let targetDate: String?

    public init(
        title: String? = nil,
        description: String? = nil,
        status: String? = nil,
        targetDate: String? = nil
    ) {
        self.title = title
        self.description = description
        self.status = status
        self.targetDate = targetDate
    }
}

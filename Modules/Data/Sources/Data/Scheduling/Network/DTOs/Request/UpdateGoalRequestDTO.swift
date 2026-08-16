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

    private enum CodingKeys: String, CodingKey {
        case title
        case description
        case status
        case targetDate
    }

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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encode(targetDate, forKey: .targetDate)
    }
}

//
//  UpdateTaskRequestDTO.swift
//  Data
//

import Foundation

public struct UpdateTaskRequestDTO: Encodable, Sendable {
    public let title: String?
    public let description: String?
    public let estimatedDuration: Int?
    public let status: String?
    public let mandatory: Bool?
    public let estimatedPoints: Int?
    public let isSplittable: Bool?

    private enum CodingKeys: String, CodingKey {
        case title
        case description
        case estimatedDuration
        case status
        case mandatory
        case estimatedPoints
        case isSplittable = "allowTaskSplitting"
    }

    public init(
        title: String? = nil,
        description: String? = nil,
        estimatedDuration: Int? = nil,
        status: String? = nil,
        mandatory: Bool? = nil,
        estimatedPoints: Int? = nil,
        isSplittable: Bool? = nil
    ) {
        self.title = title
        self.description = description
        self.estimatedDuration = estimatedDuration
        self.status = status
        self.mandatory = mandatory
        self.estimatedPoints = estimatedPoints
        self.isSplittable = isSplittable
    }
}

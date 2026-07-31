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
    public let categoryID: UUID?

    private enum CodingKeys: String, CodingKey {
        case title
        case description
        case estimatedDuration
        case status
        case mandatory
        case estimatedPoints
        case isSplittable = "allowTaskSplitting"
        case categoryID = "categoryId"
    }

    public init(
        title: String? = nil,
        description: String? = nil,
        estimatedDuration: Int? = nil,
        status: String? = nil,
        mandatory: Bool? = nil,
        estimatedPoints: Int? = nil,
        isSplittable: Bool? = nil,
        categoryID: UUID? = nil
    ) {
        self.title = title
        self.description = description
        self.estimatedDuration = estimatedDuration
        self.status = status
        self.mandatory = mandatory
        self.estimatedPoints = estimatedPoints
        self.isSplittable = isSplittable
        self.categoryID = categoryID
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(estimatedDuration, forKey: .estimatedDuration)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(mandatory, forKey: .mandatory)
        try container.encodeIfPresent(estimatedPoints, forKey: .estimatedPoints)
        try container.encodeIfPresent(isSplittable, forKey: .isSplittable)
        try container.encode(categoryID, forKey: .categoryID)
    }
}

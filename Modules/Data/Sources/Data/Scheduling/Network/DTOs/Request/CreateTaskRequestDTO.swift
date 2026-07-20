//
//  CreateTaskRequestDTO.swift
//  Data
//

import Foundation

public struct CreateTaskRequestDTO: Encodable, Sendable {
    public let title: String
    public let description: String?
    public let estimatedDuration: Int?
    public let mandatory: Bool?
    public let estimatedPoints: Int?
    public let isSplittable: Bool?
    public let goalID: UUID?

    private enum CodingKeys: String, CodingKey {
        case title
        case description
        case estimatedDuration
        case mandatory
        case estimatedPoints
        case isSplittable = "allowTaskSplitting"
        case goalID = "goalId"
    }

    public init(
        title: String,
        description: String? = nil,
        estimatedDuration: Int? = nil,
        mandatory: Bool? = nil,
        estimatedPoints: Int? = nil,
        isSplittable: Bool? = nil,
        goalID: UUID? = nil
    ) {
        self.title = title
        self.description = description
        self.estimatedDuration = estimatedDuration
        self.mandatory = mandatory
        self.estimatedPoints = estimatedPoints
        self.isSplittable = isSplittable
        self.goalID = goalID
    }
}

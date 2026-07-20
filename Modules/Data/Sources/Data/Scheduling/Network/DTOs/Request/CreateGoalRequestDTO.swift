//
//  CreateGoalRequestDTO.swift
//  Data
//

import Foundation

public struct CreateGoalRequestDTO: Encodable, Sendable {
    public let title: String
    public let description: String?
    public let targetDate: String?
    public let tasks: [CreateGoalTaskRequestDTO]?

    public init(
        title: String,
        description: String? = nil,
        targetDate: String? = nil,
        tasks: [CreateGoalTaskRequestDTO]? = nil
    ) {
        self.title = title
        self.description = description
        self.targetDate = targetDate
        self.tasks = tasks
    }
}

public struct CreateGoalTaskRequestDTO: Encodable, Sendable {
    public let tempId: String
    public let title: String
    public let description: String?
    public let estimatedDuration: Int?
    public let mandatory: Bool?
    public let estimatedPoints: Int?
    public let isSplittable: Bool?
    public let dependsOnTempIDs: [String]?

    private enum CodingKeys: String, CodingKey {
        case tempId
        case title
        case description
        case estimatedDuration
        case mandatory
        case estimatedPoints
        case isSplittable = "allowTaskSplitting"
        case dependsOnTempIDs = "dependsOnTempIds"
    }

    public init(
        tempId: String,
        title: String,
        description: String? = nil,
        estimatedDuration: Int? = nil,
        mandatory: Bool? = nil,
        estimatedPoints: Int? = nil,
        isSplittable: Bool? = nil,
        dependsOnTempIDs: [String]? = nil
    ) {
        self.tempId = tempId
        self.title = title
        self.description = description
        self.estimatedDuration = estimatedDuration
        self.mandatory = mandatory
        self.estimatedPoints = estimatedPoints
        self.isSplittable = isSplittable
        self.dependsOnTempIDs = dependsOnTempIDs
    }
}

//
//  BulkAddTasksRequestDTO.swift
//  Data
//

import Foundation

public struct BulkAddTasksRequestDTO: Encodable, Sendable {
    public let tasks: [BulkAddTaskItemRequestDTO]

    public init(tasks: [BulkAddTaskItemRequestDTO]) {
        self.tasks = tasks
    }
}

public struct BulkAddTaskItemRequestDTO: Encodable, Sendable {
    public let tempId: String
    public let title: String
    public let description: String?
    public let estimatedDuration: Int?
    public let mandatory: Bool?
    public let estimatedPoints: Int?
    public let isSplittable: Bool?
    public let dependsOnRefs: [String]?

    private enum CodingKeys: String, CodingKey {
        case tempId
        case title
        case description
        case estimatedDuration
        case mandatory
        case estimatedPoints
        case isSplittable = "allowTaskSplitting"
        case dependsOnRefs
    }

    public init(
        tempId: String,
        title: String,
        description: String? = nil,
        estimatedDuration: Int? = nil,
        mandatory: Bool? = nil,
        estimatedPoints: Int? = nil,
        isSplittable: Bool? = nil,
        dependsOnRefs: [String]? = nil
    ) {
        self.tempId = tempId
        self.title = title
        self.description = description
        self.estimatedDuration = estimatedDuration
        self.mandatory = mandatory
        self.estimatedPoints = estimatedPoints
        self.isSplittable = isSplittable
        self.dependsOnRefs = dependsOnRefs
    }
}

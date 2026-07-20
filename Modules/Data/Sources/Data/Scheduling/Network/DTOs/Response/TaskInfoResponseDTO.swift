//
//  TaskInfoResponseDTO.swift
//  Data
//

import Foundation

public struct TaskInfoResponseDTO: Decodable, Sendable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let status: String
    public let goalID: UUID?
    public let estimatedDuration: Int?
    public let mandatory: Bool
    public let estimatedPoints: Int
    public let isSplittable: Bool
    public let dependencyIDs: [UUID]

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case status
        case goalID = "goalId"
        case estimatedDuration
        case mandatory
        case estimatedPoints
        case isSplittable = "allowTaskSplitting"
        case dependencyIDs = "dependsOnTaskIds"
    }

    public init(
        id: UUID,
        title: String,
        description: String?,
        status: String,
        goalID: UUID?,
        estimatedDuration: Int?,
        mandatory: Bool,
        estimatedPoints: Int,
        isSplittable: Bool,
        dependencyIDs: [UUID]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.goalID = goalID
        self.estimatedDuration = estimatedDuration
        self.mandatory = mandatory
        self.estimatedPoints = estimatedPoints
        self.isSplittable = isSplittable
        self.dependencyIDs = dependencyIDs
    }
}

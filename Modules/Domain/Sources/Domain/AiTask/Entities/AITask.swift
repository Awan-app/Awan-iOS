//
//  AITask.swift
//  Domain
//

import Foundation

public struct AITask: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let estimatedDuration: Int
    public let status: String
    public let mandatory: Bool
    public let estimatedPoints: Int
    public let isSplittable: Bool
    public let goalID: UUID
    public let dependencyIDs: [UUID]
    public let category: TaskCategory?

    public init(
        id: UUID,
        title: String,
        description: String? = nil,
        estimatedDuration: Int,
        status: String,
        mandatory: Bool,
        estimatedPoints: Int,
        isSplittable: Bool,
        goalID: UUID,
        dependencyIDs: [UUID] = [],
        category: TaskCategory? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.estimatedDuration = estimatedDuration
        self.status = status
        self.mandatory = mandatory
        self.estimatedPoints = estimatedPoints
        self.isSplittable = isSplittable
        self.goalID = goalID
        self.dependencyIDs = dependencyIDs
        self.category = category
    }
}

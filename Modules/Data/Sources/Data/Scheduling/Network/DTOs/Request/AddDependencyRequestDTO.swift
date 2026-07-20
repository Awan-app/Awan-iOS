//
//  AddDependencyRequestDTO.swift
//  Data
//

import Foundation

public struct AddDependencyRequestDTO: Encodable, Sendable {
    public let dependsOnTaskID: UUID

    private enum CodingKeys: String, CodingKey {
        case dependsOnTaskID = "dependsOnTaskId"
    }

    public init(dependsOnTaskID: UUID) {
        self.dependsOnTaskID = dependsOnTaskID
    }
}

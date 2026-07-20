//
//  MoveTaskRequestDTO.swift
//  Data
//

import Foundation

public struct MoveTaskRequestDTO: Encodable, Sendable {
    public let goalID: UUID

    private enum CodingKeys: String, CodingKey {
        case goalID = "goalId"
    }

    public init(goalID: UUID) {
        self.goalID = goalID
    }
}

//
//  UpdatePointsRequestDTO.swift
//  Data
//

import Foundation

public struct UpdatePointsRequestDTO: Encodable, Sendable {
    public let points: Int

    public init(points: Int) {
        self.points = points
    }
}

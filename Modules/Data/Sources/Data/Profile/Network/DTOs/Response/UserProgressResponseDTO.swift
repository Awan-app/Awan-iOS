//
//  UserProgressResponseDTO.swift
//  Data
//

import Foundation

public struct UserProgressResponseDTO: Decodable, Sendable {
    public let points: Int
    public let streak: Int
    public let maxStreak: Int

    public init(points: Int, streak: Int, maxStreak: Int) {
        self.points = points
        self.streak = streak
        self.maxStreak = maxStreak
    }
}

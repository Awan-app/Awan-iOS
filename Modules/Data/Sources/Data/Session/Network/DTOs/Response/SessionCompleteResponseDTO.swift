//
//  SessionCompleteResponseDTO.swift
//  Data
//
//  Created by Eslam Elnady on 08/08/2026.
//


import Foundation

public struct SessionCompleteResponseDTO: Decodable, Sendable {
    public let session: SessionResponseDTO
    public let reward: CompletionRewardDTO
}

public struct CompletionRewardDTO: Decodable, Sendable {
    public let points: PointsRewardDTO
    public let streak: StreakRewardDTO
}

public typealias SessionCompletionRewardDTO = CompletionRewardDTO

public struct PointsRewardDTO: Decodable, Sendable {
    public let awarded: Bool
    public let amount: Int
    public let oldValue: Int
    public let newValue: Int
}

public struct StreakRewardDTO: Decodable, Sendable {
    public let updated: Bool
    public let oldValue: Int
    public let newValue: Int

    public let maxStreakBroken: Bool
    public let maxStreakOld: Int
    public let maxStreakNew: Int
}

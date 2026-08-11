//
//  FetchUserPointsUseCase.swift
//  Domain
//

import Foundation

public protocol FetchUserPointsUseCase: Sendable {
    func execute() async throws -> Int
}

public struct DefaultFetchUserPointsUseCase: FetchUserPointsUseCase {
    private let repository: any GamificationRepository

    public init(repository: any GamificationRepository) {
        self.repository = repository
    }

    public func execute() async throws -> Int {
        try await repository.fetchUserPoints()
    }
}

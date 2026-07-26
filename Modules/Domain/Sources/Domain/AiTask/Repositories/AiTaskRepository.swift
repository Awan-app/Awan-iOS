//
//  AiTaskRepository.swift
//  Domain
//

import Foundation

public protocol AiTaskRepository: Sendable {
    func createAITask(title: String, description: String?) async throws -> AwanTask
}

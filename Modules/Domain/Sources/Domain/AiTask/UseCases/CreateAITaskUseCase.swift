//
//  CreateAITaskUseCase.swift
//  Domain
//

import Foundation

public protocol CreateAITaskUseCase: Sendable {
    func execute(_ request: CreateAITaskRequest) async throws -> AITaskSheetItem
}

public struct DefaultCreateAITaskUseCase: CreateAITaskUseCase {
    private let repository: any AiTaskRepository

    public init(repository: any AiTaskRepository) {
        self.repository = repository
    }

    public func execute(_ request: CreateAITaskRequest) async throws -> AITaskSheetItem {
        try await repository.createAITask(
            title: request.title,
            description: request.description
        )
    }
}

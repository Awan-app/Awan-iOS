//
//  CreateAITaskUseCase.swift
//  Domain
//

import Foundation

public protocol CreateAITaskUseCase: Sendable {
    func execute(_ request: CreateAITaskRequest) async throws -> TaskProposal
}

public struct DefaultCreateAITaskUseCase: CreateAITaskUseCase {
    private let repository: any AiTaskRepository

    public init(repository: any AiTaskRepository) {
        self.repository = repository
    }

    public func execute(_ request: CreateAITaskRequest) async throws -> TaskProposal {
        try await repository.createAITask(
            text: request.text
        )
    }
}

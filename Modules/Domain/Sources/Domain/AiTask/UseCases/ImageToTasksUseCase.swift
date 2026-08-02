//
//  ImageToTasksUseCase.swift
//  Domain
//

import Foundation

public protocol ImageToTasksUseCase: Sendable {
    func execute(imageData: Data, mimeType: String, note: String?) async throws -> TaskProposal
}

public struct DefaultImageToTasksUseCase: ImageToTasksUseCase {
    private let repository: any AiTaskRepository

    public init(repository: any AiTaskRepository) {
        self.repository = repository
    }

    public func execute(imageData: Data, mimeType: String, note: String?) async throws -> TaskProposal {
        try await repository.imageToTasks(imageData: imageData, mimeType: mimeType, note: note)
    }
}

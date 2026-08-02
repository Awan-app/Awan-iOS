//
//  AiTaskRepository.swift
//  Domain
//

import Foundation

public protocol AiTaskRepository: Sendable {
    func createAITask(text: String) async throws -> TaskProposal
    func imageToTasks(imageData: Data, mimeType: String, note: String?) async throws -> TaskProposal
    func acceptTaskWithSessions(_ draft: TaskWithSessionsDraft) async throws -> AwanTask
}

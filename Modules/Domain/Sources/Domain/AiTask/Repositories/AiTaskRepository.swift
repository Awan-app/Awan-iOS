//
//  AiTaskRepository.swift
//  Domain
//

import Foundation

public protocol AiTaskRepository: Sendable {
    func createAITask(title: String, description: String?) async throws -> AwanTask
    func imageToTasks(imageData: Data, mimeType: String, note: String?) async throws -> TaskProposalResponse
    func acceptTaskWithSessions(_ draft: TaskWithSessionsDraft) async throws -> AwanTask
}

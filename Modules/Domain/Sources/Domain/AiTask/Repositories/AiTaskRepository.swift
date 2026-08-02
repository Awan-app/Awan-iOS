//
//  AiTaskRepository.swift
//  Domain
//

import Foundation

public protocol AiTaskRepository: Sendable {
    func createAITask(text: String) async throws -> TaskProposalResponse
    func imageToTasks(imageData: Data, mimeType: String, note: String?) async throws -> TaskProposalResponse
    func acceptTaskWithSessions(_ draft: TaskWithSessionsDraft) async throws -> AwanTask
}

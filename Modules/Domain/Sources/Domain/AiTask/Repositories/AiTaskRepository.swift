//
//  AiTaskRepository.swift
//  Domain
//

import Foundation

public protocol AiTaskRepository: Sendable {
    func createAITask(text: String) async throws -> [AITaskSheetItem]
}

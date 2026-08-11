//
//  RemoteAiTaskDataSource.swift
//  Data
//

import Foundation
import AwaNetwork

public protocol AiTaskRemoteDataSource: Sendable {
    func createAITask(_ request: CreateAITaskRequestDTO) async throws -> TaskProposalResponseDTO
    func imageToTasks(imageData: Data, mimeType: String, note: String?) async throws -> TaskProposalResponseDTO
    func acceptTaskWithSessions(_ request: CreateTaskWithSessionsRequestDTO) async throws -> TaskWithSessionsResponseDTO
    func acceptTasksWithSessions(_ request: BulkCreateTasksWithSessionsRequestDTO) async throws -> TasksWithSessionsResponseDTO
}

public final class DefaultAiTaskRemoteDataSource: AiTaskRemoteDataSource {
    private let networkService: any NetworkServiceProtocol
    public init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func createAITask(_ request: CreateAITaskRequestDTO) async throws -> TaskProposalResponseDTO {
        try await networkService.request(AiTaskEndpoint.createAITask(request))
    }

    public func imageToTasks(imageData: Data, mimeType: String, note: String?) async throws -> TaskProposalResponseDTO {
        var params: [String: String]? = nil
        if let note, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            params = ["note": note]
        }
        let ext = mimeType.contains("png") ? "png" : "jpg"
        let file = MultipartFile(
            data: imageData,
            name: "image",
            fileName: "image.\(ext)",
            mimeType: mimeType
        )
        return try await networkService.uploadMultipart(
            AiTaskEndpoint.imageToTasks,
            files: [file],
            parameters: params
        )
    }

    public func acceptTaskWithSessions(
        _ request: CreateTaskWithSessionsRequestDTO
    ) async throws -> TaskWithSessionsResponseDTO {
        try await networkService.request(TaskEndpoint.createTaskWithSessions(request))
    }

    public func acceptTasksWithSessions(
        _ request: BulkCreateTasksWithSessionsRequestDTO
    ) async throws -> TasksWithSessionsResponseDTO {
        try await networkService.request(TaskEndpoint.createTasksWithSessions(request))
    }
}

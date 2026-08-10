import Foundation

public protocol SetTaskCompletionUseCase: Sendable {
    func execute(
        taskID: UUID,
        isCompleted: Bool
    ) async throws -> SetTaskCompletionResult
}

public struct DefaultSetTaskCompletionUseCase: SetTaskCompletionUseCase {
    private let taskRepository: any TaskRepository
    private let userProfileRepository: any UserProfileRepository

    public init(
        taskRepository: any TaskRepository,
        userProfileRepository: any UserProfileRepository
    ) {
        self.taskRepository = taskRepository
        self.userProfileRepository = userProfileRepository
    }

    public func execute(
        taskID: UUID,
        isCompleted: Bool
    ) async throws -> SetTaskCompletionResult {
        if isCompleted {
            let result = try await taskRepository.completeTask(id: taskID)
            try? await userProfileRepository.refreshGamificationProgress()
            return .completed(result)
        }

        return .uncompleted(
            try await taskRepository.uncompleteTask(id: taskID)
        )
    }
}

import Foundation

public protocol UpdateProfilePictureUseCase: Sendable {
    func execute(data: Data, fileName: String, mimeType: String) async throws
}

public struct DefaultUpdateProfilePictureUseCase: UpdateProfilePictureUseCase {
    private let repository: any UserProfileRepository

    public init(repository: any UserProfileRepository) {
        self.repository = repository
    }

    public func execute(data: Data, fileName: String, mimeType: String) async throws {
        try await repository.updateProfilePicture(data: data, fileName: fileName, mimeType: mimeType)
    }
}

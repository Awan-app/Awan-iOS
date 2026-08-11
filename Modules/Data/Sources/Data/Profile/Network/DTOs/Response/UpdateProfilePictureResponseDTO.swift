import Foundation

public struct UpdateProfilePictureResponseDTO: Decodable, Sendable {
    public let profilePictureUrl: String
    
    public init(profilePictureUrl: String) {
        self.profilePictureUrl = profilePictureUrl
    }
}

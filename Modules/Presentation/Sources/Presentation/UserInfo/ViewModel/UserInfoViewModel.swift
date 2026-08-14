import SwiftUI
import Observation
import Domain
import Combine

@MainActor
@Observable
public final class UserInfoViewModel {
    public var firstName: String = ""
    public var lastName: String = ""
    public var email: String = ""
    public var dateOfBirth: Date = Calendar.current.date(from: DateComponents(year: 2000, month: 7, day: 21)) ?? Date()
    public var profileImageData: Data?
    public var profileImageMimeType: String?
    public var profileImageFileName: String?
    public var profilePictureUrl: String?
    public var frameImageUrl: String?
    
    public var showToast: Bool = false
    public var toastMessage: String?
    public var isSaving: Bool = false
    
    @ObservationIgnored
    private var profileCancellable: AnyCancellable?
    
    private let getUserProfileUseCase: any GetUserProfileUseCase
    private let updateUserProfileUseCase: any UpdateUserProfileUseCase
    private let updateProfilePictureUseCase: any UpdateProfilePictureUseCase
    
    public init(
        getUserProfileUseCase: any GetUserProfileUseCase,
        updateUserProfileUseCase: any UpdateUserProfileUseCase,
        updateProfilePictureUseCase: any UpdateProfilePictureUseCase
    ) {
        self.getUserProfileUseCase = getUserProfileUseCase
        self.updateUserProfileUseCase = updateUserProfileUseCase
        self.updateProfilePictureUseCase = updateProfilePictureUseCase
    }
    
    public var isSaveDisabled: Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public func observeUserProfile() {
        profileCancellable = getUserProfileUseCase.observe()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to observe profile: \(error)")
                    }
                },
                receiveValue: { [weak self] profile in
                    guard let self = self else { return }
                    self.firstName = profile.firstName
                    self.lastName = profile.lastName
                    self.email = profile.email
                    self.profilePictureUrl =
                    "data:image/jpeg;base64,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"
                    //profile.profilePictureUrl
                    
                    if let frameItem = profile.equippedItems.first(where: { $0.type == .frame }) {
                        self.frameImageUrl = frameItem.item.image
                    } else {
                        self.frameImageUrl = nil
                    }
                    
                    var components = DateComponents()
                    components.year = profile.birthDate.year
                    components.month = profile.birthDate.month
                    components.day = profile.birthDate.day
                    if let date = Calendar.current.date(from: components) {
                        self.dateOfBirth = date
                    } else {
                        self.dateOfBirth = Calendar.current.date(from: DateComponents(year: 2000, month: 7, day: 21)) ?? Date()
                    }
                }
            )
    }
    
    public func saveChanges() async {
        isSaving = true
        defer { isSaving = false }
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let birthDateString = dateFormatter.string(from: dateOfBirth)
            
            try await updateUserProfileUseCase.execute(
                firstName: firstName,
                lastName: lastName,
                birthDate: birthDateString
            )
            
            if let imageData = profileImageData,
               let mimeType = profileImageMimeType,
               let fileName = profileImageFileName {
                do {
                    try await updateProfilePictureUseCase.execute(data: imageData, fileName: fileName, mimeType: mimeType)
                } catch {
                    print("Failed to save profile picture: \(error)")
                    withAnimation {
                        self.toastMessage = error.localizedDescription
                        self.showToast = true
                    }
                }
            }
        } catch {
            print("Failed to save profile changes: \(error)")
            withAnimation {
                self.toastMessage = error.localizedDescription
                self.showToast = true
            }
        }
    }
}

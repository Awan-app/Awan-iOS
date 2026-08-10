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
                    self.profilePictureUrl = profile.profilePictureUrl
                    
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

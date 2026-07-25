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
    
    @ObservationIgnored
    private var profileCancellable: AnyCancellable?
    
    private let getUserProfileUseCase: any GetUserProfileUseCase
    private let updateUserNameUseCase: any UpdateUserNameUseCase
    
    public init(
        getUserProfileUseCase: any GetUserProfileUseCase,
        updateUserNameUseCase: any UpdateUserNameUseCase
    ) {
        self.getUserProfileUseCase = getUserProfileUseCase
        self.updateUserNameUseCase = updateUserNameUseCase
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
        do {
            try await updateUserNameUseCase.execute(firstName: firstName, lastName: lastName)
        } catch {
            print("Failed to save profile changes: \(error)")
        }
    }
}

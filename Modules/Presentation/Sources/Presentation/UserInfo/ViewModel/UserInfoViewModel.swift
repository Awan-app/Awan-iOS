import SwiftUI
import Observation
import Domain

@MainActor
@Observable
public final class UserInfoViewModel {
    public var firstName: String = ""
    public var lastName: String = ""
    public var email: String = ""
    public var dateOfBirth: Date = Calendar.current.date(from: DateComponents(year: 2000, month: 7, day: 21)) ?? Date()
    public var profileImageData: Data?
    
    private let getUserProfileUseCase: any GetUserProfileUseCase
    
    public init(getUserProfileUseCase: any GetUserProfileUseCase) {
        self.getUserProfileUseCase = getUserProfileUseCase
    }
    
    public var isSaveDisabled: Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public func fetchUserProfile() async {
        do {
            let profile = try await getUserProfileUseCase.execute()
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
        } catch {
            print("Failed to fetch profile: \(error)")
        }
    }
    
    public func saveChanges() async {
        // Mock save
        try? await Task.sleep(for: .seconds(1))
    }
}

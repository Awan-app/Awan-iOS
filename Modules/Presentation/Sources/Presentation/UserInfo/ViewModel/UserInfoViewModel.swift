import SwiftUI
import Observation

@MainActor
@Observable
public final class UserInfoViewModel {
    public var firstName: String
    public var lastName: String
    public var email: String
    public var dateOfBirth: Date
    public var profileImageData: Data?
    
    public init(firstName: String = "Sam",
                lastName: String = "Rivera",
                email: String = "sam@awan.app",
                dateOfBirth: Date = Calendar.current.date(from: DateComponents(year: 2000, month: 7, day: 21)) ?? Date()) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.dateOfBirth = dateOfBirth
    }
    
    public func saveChanges() async {
        // Mock save
        try? await Task.sleep(for: .seconds(1))
    }
}

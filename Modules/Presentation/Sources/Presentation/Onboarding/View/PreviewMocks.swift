import Domain
import SwiftUI

#if DEBUG
public struct MockCompleteOnboardingUseCase: CompleteOnboardingUseCase {
    public init() {}
    public func execute(_ request: CompleteOnboardingRequest) async throws -> UserProfile {
        fatalError("Not implemented in preview mock")
    }
}

extension OnboardingViewModel {
    public static var preview: OnboardingViewModel {
        OnboardingViewModel(completeOnboardingUseCase: MockCompleteOnboardingUseCase())
    }
}
#endif

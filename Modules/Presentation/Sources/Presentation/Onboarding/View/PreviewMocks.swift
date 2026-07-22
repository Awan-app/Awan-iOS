import Domain
import SwiftUI

#if DEBUG
public struct MockCompleteOnboardingUseCase: CompleteOnboardingUseCase {
    public init() {}
    public func execute(_ request: CompleteOnboardingRequest) async throws -> UserProfile {
        fatalError("Not implemented in preview mock")
    }
}

public struct MockCreateOnboardingTemplateUseCase: CreateOnboardingTemplateUseCase {
    public init() {}
    public func execute(zoneDrafts: [ZoneDraft]) async throws {}
}

extension OnboardingViewModel {
    public static var preview: OnboardingViewModel {
        OnboardingViewModel(
            completeOnboardingUseCase: MockCompleteOnboardingUseCase(),
            createOnboardingTemplateUseCase: MockCreateOnboardingTemplateUseCase(),
            manageZoneScheduleUseCase: ManageZoneScheduleUseCaseImpl()
        )
    }
}
#endif

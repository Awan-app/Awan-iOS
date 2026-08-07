import Domain
import XCTest
@testable import Presentation

@MainActor
final class OnboardingViewModelTests: XCTestCase {
    func testSetLaterCreatesTemplateWithoutZones() async throws {
        let templateUseCase = OnboardingTemplateUseCaseSpy()
        let viewModel = OnboardingViewModel(
            completeOnboardingUseCase: CompleteOnboardingUseCaseStub(),
            createOnboardingTemplateUseCase: templateUseCase,
            manageZoneScheduleUseCase: ManageZoneScheduleUseCaseImpl(),
            fetchCategoriesUseCase: MockFetchCategoriesUseCase()
        )
        viewModel.firstName = "Awan"
        viewModel.lastName = "User"

        XCTAssertFalse(viewModel.suggestedZones.isEmpty)

        viewModel.setZoneSetupForLater()
        await viewModel.completeOnboarding()

        let receivedZones = await templateUseCase.receivedZones()
        XCTAssertEqual(receivedZones, [])
        XCTAssertNil(viewModel.completionErrorMessage)
    }
}

private actor OnboardingTemplateUseCaseSpy: CreateOnboardingTemplateUseCase {
    private var zones: [Zone]?

    func execute(zoneDrafts: [Zone]) {
        zones = zoneDrafts
    }

    func receivedZones() -> [Zone]? {
        zones
    }
}

private struct CompleteOnboardingUseCaseStub: CompleteOnboardingUseCase {
    func execute(_ request: CompleteOnboardingRequest) async throws -> UserProfile {
        UserProfile(
            id: UUID(),
            email: "user@example.com",
            firstName: request.firstName,
            lastName: request.lastName,
            birthDate: request.birthDate,
            points: 0,
            streak: 0,
            maxStreak: 0,
            preferences: UserPreferences(
                timezone: request.timezone,
                preferredSessionDuration: request.preferredSessionDuration,
                bufferBetweenSessions: request.bufferBetweenSessions,
                wakeupTime: request.wakeupTime,
                sleepTime: request.sleepTime
            )
        )
    }
}

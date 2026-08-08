import Domain
import Foundation
import XCTest
@testable import Presentation

@MainActor
final class OnboardingViewModelTests: XCTestCase {
    func testFocusDurationSelectionBoundaries() throws {
        let viewModel = OnboardingViewModel(
            completeOnboardingUseCase: MockCompleteOnboardingUseCase(),
            createOnboardingTemplateUseCase: MockCreateOnboardingTemplateUseCase(),
            manageZoneScheduleUseCase: ManageZoneScheduleUseCaseImpl()
        )
        
        let durations = OnboardingViewModel.sessionDurations
        XCTAssertEqual(durations.first, 10, "Minimum focus duration should be 10 minutes")
        XCTAssertEqual(durations.last, 180, "Maximum focus duration should be 180 minutes (3 hours)")
        XCTAssertTrue(durations.contains(60), "Should include 60 minutes boundary")
        XCTAssertTrue(durations.contains(120), "Should include 120 minutes boundary")
        
        // 10 -> 60: 5 min steps
        XCTAssertEqual(durations[0...10], [10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60])
        
        // 60 -> 120: 15 min steps
        XCTAssertEqual(durations[11...14], [75, 90, 105, 120])
        
        // 120 -> 180: 30 min steps
        XCTAssertEqual(durations[15...16], [150, 180])
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

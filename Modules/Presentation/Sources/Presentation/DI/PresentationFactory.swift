import SwiftUI

@MainActor
public struct PresentationFactory {
    private let appCoordinator: AppCoordinator
    private let authenticationState: AuthenticationState
    private let makeLoginViewModel: () -> LoginViewModel
    private let makeHomeViewModel: () -> HomeViewModel
    private let makeDailyWheelViewModel: () -> DailyWheelViewModel
    private let makeCalendarViewModel: () -> CalendarViewModel
    private let makeScheduleViewModel: () -> ScheduleTimelineViewModel
    private let creationUseCases: CreationUseCases
    private let makeOtpViewModel: (OtpVerificationContext) -> OtpVerificationViewModel
    private let makeOnboardingViewModel: () -> OnboardingViewModel
    private let makeProfileViewModel: () -> ProfileViewModel
    private let makeSettingsViewModel: () -> SettingsViewModel
    private let makeDailyZonesViewModel: () -> DailyZonesViewModel
    private let makeUserInfoViewModel: () -> UserInfoViewModel
    private let makeInboxViewModel: () -> InboxViewModel
    private let makeGoalsViewModel: () -> GoalsViewModel
    private let makeMarketplaceViewModel: () -> MarketplaceViewModel
    private let makeProfileInventoryViewModel: () -> ProfileInventoryViewModel
    private let activeViewModels = ActivePresentationViewModels()

    public init(
        appCoordinator: AppCoordinator,
        authenticationState: AuthenticationState,
        makeLoginViewModel: @escaping () -> LoginViewModel,
        makeHomeViewModel: @escaping () -> HomeViewModel,
        makeDailyWheelViewModel: @escaping () -> DailyWheelViewModel,
        makeCalendarViewModel: @escaping () -> CalendarViewModel,
        makeScheduleViewModel: @escaping () -> ScheduleTimelineViewModel,
        creationUseCases: CreationUseCases,
        makeOtpViewModel: @escaping (OtpVerificationContext) -> OtpVerificationViewModel,
        makeOnboardingViewModel: @escaping () -> OnboardingViewModel,
        makeProfileViewModel: @escaping () -> ProfileViewModel,
        makeSettingsViewModel: @escaping () -> SettingsViewModel,
        makeDailyZonesViewModel: @escaping () -> DailyZonesViewModel,
        makeUserInfoViewModel: @escaping () -> UserInfoViewModel,
        makeInboxViewModel: @escaping () -> InboxViewModel,
        makeGoalsViewModel: @escaping () -> GoalsViewModel,
        makeMarketplaceViewModel: @escaping () -> MarketplaceViewModel,
        makeProfileInventoryViewModel: @escaping () -> ProfileInventoryViewModel
    ) {
        self.appCoordinator = appCoordinator
        self.authenticationState = authenticationState
        self.makeLoginViewModel = makeLoginViewModel
        self.makeHomeViewModel = makeHomeViewModel
        self.makeDailyWheelViewModel = makeDailyWheelViewModel
        self.makeCalendarViewModel = makeCalendarViewModel
        self.makeScheduleViewModel = makeScheduleViewModel
        self.creationUseCases = creationUseCases
        self.makeOtpViewModel = makeOtpViewModel
        self.makeOnboardingViewModel = makeOnboardingViewModel
        self.makeProfileViewModel = makeProfileViewModel
        self.makeSettingsViewModel = makeSettingsViewModel
        self.makeDailyZonesViewModel = makeDailyZonesViewModel
        self.makeUserInfoViewModel = makeUserInfoViewModel
        self.makeInboxViewModel = makeInboxViewModel
        self.makeGoalsViewModel = makeGoalsViewModel
        self.makeMarketplaceViewModel = makeMarketplaceViewModel
        self.makeProfileInventoryViewModel = makeProfileInventoryViewModel
    }

    public func makeAppRootView() -> some View {
        AppRootView(factory: self)
            .environment(appCoordinator)
            .environment(authenticationState)
    }

    func makeLoginView() -> some View {
        LoginView(viewModel: makeLoginViewModel())
    }

    func makeOtpVerificationView(context: OtpVerificationContext) -> some View {
        OtpVerificationView(viewModel: makeOtpViewModel(context))
    }

    func makeHomeView() -> some View {
        HomeView(
            viewModel: makeHomeViewModel(),
            onBecameActive: { activeViewModels.home = $0 }
        )
    }

    func makeDailyWheelPresentationLayer(
        alwaysShowsFloatingButton: Bool
    ) -> some View {
        DailyWheelPresentationLayer(
            viewModel: makeDailyWheelViewModel(),
            alwaysShowsFloatingButton: alwaysShowsFloatingButton
        )
    }

    func makeScheduleTimelineView() -> some View {
        ScheduleTimelineView(
            viewModel: makeScheduleViewModel(),
            onBecameActive: { activeViewModels.schedule = $0 }
        )
    }

    public func refreshScheduleTimeline() {
        activeViewModels.schedule?.send(.appeared)
    }

    func makeGlobalCreationSheet(
        onDismiss: @escaping () -> Void,
        onTaskLayoutModeChanged: @escaping (Bool, Bool) -> Void,
        onGoalFullScreenChanged: @escaping (Bool) -> Void
    ) -> some View {
        GlobalCreationSheet(
            taskViewModel: CreateTaskViewModel(
                useCases: creationUseCases,
                speechTranscriber: LiveSpeechTranscriber(),
                selectedDay: activeViewModels.schedule?.state.selectedDay ?? .now
            ),
            goalViewModel: CreateGoalViewModel(
                useCases: creationUseCases.goalDecomposition,
                speechTranscriber: LiveSpeechTranscriber()
            ),
            onDismiss: onDismiss,
            onTaskLayoutModeChanged: onTaskLayoutModeChanged,
            onGoalFullScreenChanged: onGoalFullScreenChanged
        )
    }

    func makeCalendarView() -> some View {
        CalendarView(
            viewModel: makeCalendarViewModel(),
            onSelectDate: { date in
                activeViewModels.home?.send(.selectDay(date))
            }
        )
    }

    func makeRewardsView() -> some View {
        RewardsView()
    }

    func makeInboxView() -> some View {
        InboxView(
            viewModel: makeInboxViewModel(),
            goalsViewModel: makeGoalsViewModel()
        )
    }

    func makeMarketplaceView() -> some View {
        MarketplaceView(viewModel: makeMarketplaceViewModel())
    }

    func makeInboxTaskDetailView(taskID: UUID) -> some View {
        // Placeholder until inbox task detail is implemented.
        EmptyView()
            .accessibilityIdentifier("inbox-task-detail-\(taskID.uuidString)")
    }

    func makeGoalDetailView(goalID: UUID) -> GoalDetailView {
        GoalDetailView(goalID: goalID, viewModel: makeGoalsViewModel())
    }

    func makeYouView() -> some View {
        makeProfileMainView()
    }

    func makeOnboardingWelcomeView() -> some View {
        OnboardingWelcomeView(viewModel: makeOnboardingViewModel())
    }

    func makeOnboardingContainerView() -> some View {
        OnboardingContainerView(
            viewModel: makeOnboardingViewModel()
        )
    }

    public func makeProfileMainView() -> some View {
        ProfileMainView(viewModel: makeProfileViewModel())
    }

    func makePersonalizationView() -> some View {
        PersonalizationView(viewModel: makeSettingsViewModel())
    }

    func makeSettingsView() -> some View {
        SettingsView()
    }

    func makeAboutAwanView() -> some View {
        AboutAwanView()
    }

    func makeDailyZonesView() -> some View {
        DailyZonesView(viewModel: makeDailyZonesViewModel())
    }
    func makeUserInfoView() -> some View {
        UserInfoView(viewModel: makeUserInfoViewModel())
    }

    func makeProfileInventoryView() -> some View {
        ProfileInventoryView(viewModel: makeProfileInventoryViewModel())
    }
}

@MainActor
private final class ActivePresentationViewModels {
    weak var home: HomeViewModel?
    weak var schedule: ScheduleTimelineViewModel?
}

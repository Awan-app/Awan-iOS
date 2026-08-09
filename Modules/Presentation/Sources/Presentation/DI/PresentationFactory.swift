import SwiftUI

@MainActor
public struct PresentationFactory {
    private let appCoordinator: AppCoordinator
    private let authenticationState: AuthenticationState
    private let loginViewModel: LoginViewModel
    private let homeViewModel: HomeViewModel
    private let dailyWheelViewModel: DailyWheelViewModel
    private let calendarViewModel: CalendarViewModel
    private let scheduleViewModel: ScheduleTimelineViewModel
    private let creationUseCases: CreationUseCases
    private let makeOtpViewModel: (OtpVerificationContext) -> OtpVerificationViewModel
    private let onboardingViewModel: OnboardingViewModel
    private let profileViewModel: ProfileViewModel
    private let settingsViewModel: SettingsViewModel
    private let dailyZonesViewModel: DailyZonesViewModel
    private let makeUserInfoViewModel: () -> UserInfoViewModel
    private let inboxViewModel: InboxViewModel
    private let goalsViewModel: GoalsViewModel
    private let marketplaceViewModel: MarketplaceViewModel

    public init(
        appCoordinator: AppCoordinator,
        authenticationState: AuthenticationState,
        loginViewModel: LoginViewModel,
        homeViewModel: HomeViewModel,
        dailyWheelViewModel: DailyWheelViewModel,
        calendarViewModel: CalendarViewModel,
        scheduleViewModel: ScheduleTimelineViewModel,
        creationUseCases: CreationUseCases,
        makeOtpViewModel: @escaping (OtpVerificationContext) -> OtpVerificationViewModel,
        onboardingViewModel: OnboardingViewModel,
        profileViewModel: ProfileViewModel,
        settingsViewModel: SettingsViewModel,
        dailyZonesViewModel: DailyZonesViewModel,
        makeUserInfoViewModel: @escaping () -> UserInfoViewModel,
        inboxViewModel: InboxViewModel,
        goalsViewModel: GoalsViewModel,
        marketplaceViewModel: MarketplaceViewModel = MarketplaceViewModel()
    ) {
        self.appCoordinator = appCoordinator
        self.authenticationState = authenticationState
        self.loginViewModel = loginViewModel
        self.homeViewModel = homeViewModel
        self.dailyWheelViewModel = dailyWheelViewModel
        self.calendarViewModel = calendarViewModel
        self.scheduleViewModel = scheduleViewModel
        self.creationUseCases = creationUseCases
        self.makeOtpViewModel = makeOtpViewModel
        self.onboardingViewModel = onboardingViewModel
        self.profileViewModel = profileViewModel
        self.settingsViewModel = settingsViewModel
        self.dailyZonesViewModel = dailyZonesViewModel
        self.makeUserInfoViewModel = makeUserInfoViewModel
        self.inboxViewModel = inboxViewModel
        self.goalsViewModel = goalsViewModel
        self.marketplaceViewModel = marketplaceViewModel
        if self.inboxViewModel.goalsViewModel == nil {
            self.inboxViewModel.goalsViewModel = goalsViewModel
        }
    }

    public func makeAppRootView() -> some View {
        AppRootView(factory: self)
            .environment(appCoordinator)
            .environment(authenticationState)
    }

    func makeLoginView() -> some View {
        LoginView(viewModel: loginViewModel)
    }

    func makeOtpVerificationView(context: OtpVerificationContext) -> some View {
        OtpVerificationView(viewModel: makeOtpViewModel(context))
    }

    func makeHomeView() -> some View {
        HomeView(viewModel: homeViewModel)
    }

    func makeDailyWheelPresentationLayer(
        isHomeRootVisible: Bool
    ) -> some View {
        DailyWheelPresentationLayer(
            viewModel: dailyWheelViewModel,
            isHomeRootVisible: isHomeRootVisible
        )
    }

    func makeScheduleTimelineView() -> some View {
        ScheduleTimelineView(viewModel: scheduleViewModel)
    }

    public func refreshScheduleTimeline() {
        scheduleViewModel.send(.appeared)
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
                selectedDay: scheduleViewModel.state.selectedDay
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
            viewModel: calendarViewModel,
            onSelectDate: { date in
                homeViewModel.send(.selectDay(date))
            }
        )
    }

    func makeRewardsView() -> some View {
        RewardsView()
    }

    func makeInboxView() -> some View {
        InboxView(viewModel: inboxViewModel)
    }

    func makeMarketplaceView() -> some View {
        MarketplaceView(viewModel: marketplaceViewModel)
    }

    func makeInboxTaskDetailView(taskID: UUID) -> some View {
        // Placeholder until inbox task detail is implemented.
        EmptyView()
            .accessibilityIdentifier("inbox-task-detail-\(taskID.uuidString)")
    }

    func makeGoalDetailView(goalID: UUID) -> GoalDetailView {
        GoalDetailView(goalID: goalID, viewModel: goalsViewModel)
    }

    func makeYouView() -> some View {
        makeProfileMainView()
    }

    func makeOnboardingWelcomeView() -> some View {
        OnboardingWelcomeView(viewModel: onboardingViewModel)
    }

    func makeOnboardingContainerView() -> some View {
        OnboardingContainerView(
            viewModel: onboardingViewModel
        )
    }

    public func makeProfileMainView() -> some View {
        ProfileMainView(viewModel: profileViewModel)
    }

    func makePersonalizationView() -> some View {
        PersonalizationView(viewModel: settingsViewModel)
    }

    func makeSettingsView() -> some View {
        SettingsView()
    }

    func makeAboutAwanView() -> some View {
        AboutAwanView()
    }

    func makeDailyZonesView() -> some View {
        DailyZonesView(viewModel: dailyZonesViewModel)
    }
    func makeUserInfoView() -> some View {
        UserInfoView(viewModel: makeUserInfoViewModel())
    }
}

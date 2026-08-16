import SwiftUI

@MainActor
public struct PresentationFactory {
    private let appCoordinator: AppCoordinator
    private let authenticationState: AuthenticationState
    private let makeLoginViewModel: () -> LoginViewModel
    private let makeHomeViewModel: () -> HomeViewModel
    private let makeSessionDetailsViewModel: (
        SessionDetailsContext
    ) -> SessionDetailsViewModel
    private let makeTaskDetailsViewModel: (UUID) -> TaskDetailsViewModel
    private let makeDailyWheelViewModel: () -> DailyWheelViewModel
    private let makeCalendarViewModel: () -> CalendarViewModel
    private let makeScheduleViewModel: () -> ScheduleTimelineViewModel
    private let creationUseCases: CreationUseCases
    private let makeOtpViewModel: (OtpVerificationContext) -> OtpVerificationViewModel
    private let makeOnboardingViewModel: () -> OnboardingViewModel
    private let makeProfileViewModel: () -> ProfileViewModel
    private let makeSettingsViewModel: () -> SettingsViewModel
    private let makeMCPConnectionViewModel: () -> MCPConnectionViewModel
    private let makeDailyZonesViewModel: () -> DailyZonesViewModel
    private let makeCategoriesViewModel: () -> CategoriesViewModel
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
        makeSessionDetailsViewModel: @escaping (
            SessionDetailsContext
        ) -> SessionDetailsViewModel,
        makeTaskDetailsViewModel: @escaping (UUID) -> TaskDetailsViewModel,
        makeDailyWheelViewModel: @escaping () -> DailyWheelViewModel,
        makeCalendarViewModel: @escaping () -> CalendarViewModel,
        makeScheduleViewModel: @escaping () -> ScheduleTimelineViewModel,
        creationUseCases: CreationUseCases,
        makeOtpViewModel: @escaping (OtpVerificationContext) -> OtpVerificationViewModel,
        makeOnboardingViewModel: @escaping () -> OnboardingViewModel,
        makeProfileViewModel: @escaping () -> ProfileViewModel,
        makeSettingsViewModel: @escaping () -> SettingsViewModel,
        makeMCPConnectionViewModel: @escaping () -> MCPConnectionViewModel,
        makeDailyZonesViewModel: @escaping () -> DailyZonesViewModel,
        makeCategoriesViewModel: @escaping () -> CategoriesViewModel,
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
        self.makeSessionDetailsViewModel = makeSessionDetailsViewModel
        self.makeTaskDetailsViewModel = makeTaskDetailsViewModel
        self.makeDailyWheelViewModel = makeDailyWheelViewModel
        self.makeCalendarViewModel = makeCalendarViewModel
        self.makeScheduleViewModel = makeScheduleViewModel
        self.creationUseCases = creationUseCases
        self.makeOtpViewModel = makeOtpViewModel
        self.makeOnboardingViewModel = makeOnboardingViewModel
        self.makeProfileViewModel = makeProfileViewModel
        self.makeSettingsViewModel = makeSettingsViewModel
        self.makeMCPConnectionViewModel = makeMCPConnectionViewModel
        self.makeDailyZonesViewModel = makeDailyZonesViewModel
        self.makeCategoriesViewModel = makeCategoriesViewModel
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
            makeSessionDetailsViewModel: makeSessionDetailsViewModel,
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
        onTaskLayoutModeChanged: @escaping (Bool, Bool, Bool) -> Void,
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

    func makeTaskDetailsView(taskID: UUID, onDismiss: @escaping () -> Void) -> some View {
        TaskDetailsView(
            viewModel: makeTaskDetailsViewModel(taskID),
            onDismiss: onDismiss
        )
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

    func makeMCPConnectionView() -> some View {
        MCPConnectionView(viewModel: makeMCPConnectionViewModel())
    }

    func makeAboutAwanView() -> some View {
        AboutAwanView()
    }

    func makeDailyZonesView() -> some View {
        DailyZonesView(viewModel: makeDailyZonesViewModel())
    }

    func makeCategoriesManagementView() -> some View {
        CategoriesManagementView(viewModel: makeCategoriesViewModel())
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

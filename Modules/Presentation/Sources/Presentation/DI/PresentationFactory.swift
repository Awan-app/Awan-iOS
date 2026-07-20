import SwiftUI

@MainActor
public struct PresentationFactory {
    private let appCoordinator: AppCoordinator
    private let authenticationState: AuthenticationState
    private let loginViewModel: LoginViewModel
    private let scheduleViewModel: ScheduleTimelineViewModel
    private let makeOtpViewModel: (OtpVerificationContext) -> OtpVerificationViewModel
    private let onboardingViewModel: OnboardingViewModel

    public init(
        appCoordinator: AppCoordinator,
        authenticationState: AuthenticationState,
        loginViewModel: LoginViewModel,
        scheduleViewModel: ScheduleTimelineViewModel,
        makeOtpViewModel: @escaping (OtpVerificationContext) -> OtpVerificationViewModel,
        onboardingViewModel: OnboardingViewModel
    ) {
        self.appCoordinator = appCoordinator
        self.authenticationState = authenticationState
        self.loginViewModel = loginViewModel
        self.scheduleViewModel = scheduleViewModel
        self.makeOtpViewModel = makeOtpViewModel
        self.onboardingViewModel = onboardingViewModel
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

    func makeScheduleTimelineView() -> some View {
        ScheduleTimelineView(viewModel: scheduleViewModel)
    }

    func makeOnboardingWelcomeView() -> some View {
        OnboardingWelcomeView(viewModel: onboardingViewModel)
    }

    func makeOnboardingYourNameView() -> some View {
        OnboardingYourNameView(viewModel: onboardingViewModel)
    }

    func makeOnboardingWakeSleepView() -> some View {
        OnboardingWakeSleepView(viewModel: onboardingViewModel)
    }

    func makeOnboardingSuggestedZonesView() -> some View {
        OnboardingSuggestedZonesView(viewModel: onboardingViewModel)
    }

    func makeTaskLengthView() -> some View {
        TaskLength()
    }

    func makeTaskSimulationView() -> some View {
        TaskSimulation()
    }

    func makeAddRealTaskView() -> some View {
        AddRealTask()
    }

    func makeNotificationView() -> some View {
        NotificationView()
    }
}


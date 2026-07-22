import SwiftUI

@MainActor
public struct PresentationFactory {
    private let appCoordinator: AppCoordinator
    private let authenticationState: AuthenticationState
    private let loginViewModel: LoginViewModel
    private let scheduleViewModel: ScheduleTimelineViewModel
    private let makeOtpViewModel: (OtpVerificationContext) -> OtpVerificationViewModel
    private let onboardingViewModel: OnboardingViewModel
    private let profileViewModel: ProfileViewModel

    public init(
        appCoordinator: AppCoordinator,
        authenticationState: AuthenticationState,
        loginViewModel: LoginViewModel,
        scheduleViewModel: ScheduleTimelineViewModel,
        makeOtpViewModel: @escaping (OtpVerificationContext) -> OtpVerificationViewModel,
        onboardingViewModel: OnboardingViewModel,
        profileViewModel: ProfileViewModel
    ) {
        self.appCoordinator = appCoordinator
        self.authenticationState = authenticationState
        self.loginViewModel = loginViewModel
        self.scheduleViewModel = scheduleViewModel
        self.makeOtpViewModel = makeOtpViewModel
        self.onboardingViewModel = onboardingViewModel
        self.profileViewModel = profileViewModel
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

    func makeOnboardingContainerView() -> some View {
        OnboardingContainerView(
            viewModel: onboardingViewModel
        )
    }

    public func makeProfileMainView() -> some View {
        ProfileMainView(viewModel: profileViewModel)
    }

//    func makeAddRealTaskView() -> some View {
//        AddRealTask(viewModel: onboardingViewModel)
//    }
}

import SwiftUI

@MainActor
public struct PresentationFactory {
    private let appCoordinator: AppCoordinator
    private let loginViewModel: LoginViewModel
    private let scheduleViewModel: ScheduleTimelineViewModel
    private let makeOtpViewModel: (OtpVerificationContext) -> OtpVerificationViewModel

    public init(
        appCoordinator: AppCoordinator,
        loginViewModel: LoginViewModel,
        scheduleViewModel: ScheduleTimelineViewModel,
        makeOtpViewModel: @escaping (OtpVerificationContext) -> OtpVerificationViewModel
    ) {
        self.appCoordinator = appCoordinator
        self.loginViewModel = loginViewModel
        self.scheduleViewModel = scheduleViewModel
        self.makeOtpViewModel = makeOtpViewModel
    }

    public func makeAppRootView() -> some View {
        AppRootView(factory: self)
            .environment(appCoordinator)
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
}

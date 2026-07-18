import SwiftUI

public struct PresentationFactory {
    public init() {}
    
    @MainActor
    public func makeAppRootView(
        loginViewModel: LoginViewModel,
        scheduleViewModel: ScheduleTimelineViewModel,
        makeOtpViewModel: @escaping (String) -> OtpVerificationViewModel
    ) -> some View {
        AppRootView(
            loginViewModel: loginViewModel,
            scheduleViewModel: scheduleViewModel,
            makeOtpViewModel: makeOtpViewModel
        )
    }
}

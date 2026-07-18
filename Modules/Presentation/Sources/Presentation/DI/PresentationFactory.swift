import SwiftUI

public struct PresentationFactory {
    public init() {}
    
    @MainActor
    public func makeAppRootView(
        loginViewModel: LoginViewModel,
        scheduleViewModel: ScheduleTimelineViewModel
    ) -> some View {
        AppRootView(
            loginViewModel: loginViewModel,
            scheduleViewModel: scheduleViewModel
        )
    }
}

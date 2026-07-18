//
//  AppRootView.swift
//  Awan
//
//  Created by Manona on 15/07/2026.
//

import SwiftUI

struct AppRootView: View {
    @Environment(AppCoordinator.self) private var coordinator
    private let loginViewModel: LoginViewModel
    private let scheduleViewModel: ScheduleTimelineViewModel

    init(
        loginViewModel: LoginViewModel,
        scheduleViewModel: ScheduleTimelineViewModel
    ) {
        self.loginViewModel = loginViewModel
        self.scheduleViewModel = scheduleViewModel
    }

    var body: some View {
        switch coordinator.currentFlow {
        case .auth:
            NavigationStack(path: Bindable(coordinator.authCoordinator).path) {
                LoginView(viewModel: loginViewModel)
                    .navigationDestination(for: AuthRoute.self) { route in
                        switch route {
                        case .login:
                            LoginView(viewModel: loginViewModel)
                        case .otpVerification:
                            OtpVerificationView()
                        }
                    }
            }
        case .main:
            NavigationStack(path: Bindable(coordinator.mainCoordinator).path) {
                ScheduleTimelineView(viewModel: scheduleViewModel)
            }
        }
    }
}

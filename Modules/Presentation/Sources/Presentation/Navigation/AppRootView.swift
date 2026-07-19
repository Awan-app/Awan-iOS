//
//  AppRootView.swift
//  Awan
//
//  Created by Manona on 15/07/2026.
//

import SwiftUI

struct AppRootView: View {
    @Environment(AppCoordinator.self) private var coordinator
    private let factory: PresentationFactory

    init(factory: PresentationFactory) {
        self.factory = factory
    }

    var body: some View {
        switch coordinator.currentFlow {
        case .auth:
            NavigationStack(path: Bindable(coordinator.authCoordinator).path) {
                factory.makeLoginView()
                    .navigationDestination(for: AuthRoute.self) { route in
                        switch route {
                        case .login:
                            factory.makeLoginView()
                        case .otpVerification(let context):
                            factory.makeOtpVerificationView(context: context)
                        }
                    }
            }
        case .main:
            NavigationStack(path: Bindable(coordinator.mainCoordinator).path) {
                factory.makeScheduleTimelineView()
            }
        }
    }
}

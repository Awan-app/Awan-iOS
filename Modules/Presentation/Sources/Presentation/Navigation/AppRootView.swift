//
//  AppRootView.swift
//  Awan
//
//  Created by Manona on 15/07/2026.
//

import SwiftUI

struct AppRootView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(AuthenticationState.self) private var authenticationState
    private let factory: PresentationFactory

    init(factory: PresentationFactory) {
        self.factory = factory
    }

    var body: some View {
        Group {
            switch authenticationState.status {
            case .checking:
                ProgressView()
            case .unauthenticated:
                authenticationFlow
            case .authenticated:
                mainFlow
            }
        }
        .task {
            authenticationState.start()
        }
        .onChange(of: authenticationState.status) { _, status in
            if status == .unauthenticated {
                coordinator.authCoordinator.popToRoot()
            }
        }
    }

    private var authenticationFlow: some View {
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
    }

    private var mainFlow: some View {
        NavigationStack(path: Bindable(coordinator.mainCoordinator).path) {
            factory.makeScheduleTimelineView()
        }
    }
}

//
//  AppRootView.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
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
            case .authenticated(let user):
                if user.isNew {
                    onboardingFlow
                } else {
                    mainFlow
                }
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

    private var onboardingFlow: some View {
        NavigationStack(path: Bindable(coordinator.onboardingCoordinator).path) {
            // OnboardingWelcomeView stays as the NavigationStack root.
            // Its "Let's go" button pushes .yourName — unchanged.
            // .yourName now resolves to OnboardingContainerView, which
            // renders OnboardingYourNameView internally as its first step.
            factory.makeOnboardingWelcomeView()
                .navigationDestination(for: OnboardingRoute.self) { route in
                    switch route {
                    case .yourName:
                        factory.makeOnboardingContainerView()
//                    case .notification:
//                        factory.makeAddRealTaskView()
                    default:
                        EmptyView()
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
//    }
//}

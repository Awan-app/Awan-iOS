//
//  AppRootView.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import SwiftUI
import Common

struct AppRootView: View {
    private static let compactCreationDetent = PresentationDetent.height(370)
    private static let expandedCreationDetent = PresentationDetent.height(590)

    @Environment(AppCoordinator.self) private var coordinator
    @Environment(AuthenticationState.self) private var authenticationState
    @Environment(LanguageManager.self) private var languageManager
    @Environment(AppearanceManager.self)
    private var appearanceManager
    @State private var creationSheetDetent = Self.compactCreationDetent
    private let factory: PresentationFactory

    private var currentLayoutDirection: LayoutDirection {
        languageManager.currentLanguage == .arabic
            ? .rightToLeft
            : .leftToRight
    }

    private var currentLocale: Locale {
        Locale(identifier: languageManager.currentLanguage.rawValue)
    }

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
        TabView(selection: Bindable(coordinator.mainCoordinator).selectedTab) {
            NavigationStack(path: Bindable(coordinator.mainCoordinator).homePath) {
                factory.makeHomeView()
                    .navigationDestination(for: MainRoute.self) { route in
                        switch route {
                        case .calendar: factory.makeCalendarView()
                        default: EmptyView()
                        }
                    }
            }
            .tag(MainTab.home)
            .toolbar(.hidden, for: .tabBar)

            NavigationStack(path: Bindable(coordinator.mainCoordinator).rewardsPath) {
                factory.makeRewardsView()
            }
            .tag(MainTab.rewards)
            .toolbar(.hidden, for: .tabBar)

            NavigationStack(path: Bindable(coordinator.mainCoordinator).storePath) {
                AppColors.screenBackground.ignoresSafeArea()
            }
            .tag(MainTab.store)
            .toolbar(.hidden, for: .tabBar)

            NavigationStack(path: Bindable(coordinator.mainCoordinator).youPath) {
                factory.makeProfileMainView()
                    .navigationDestination(for: MainRoute.self) { route in
                        switch route {
                        case .userInfo:   factory.makeUserInfoView()
                        case .dailyZones: factory.makeDailyZonesView().environment(appearanceManager)
                        default:          EmptyView()
                        }
                    }
            }
            .tag(MainTab.you)
            .toolbar(.hidden, for: .tabBar)
        }
        .id(languageManager.currentLanguage)
        .overlay {
            opaqueTopSafeArea
        }
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(
                selectedTab: Bindable(coordinator.mainCoordinator).selectedTab,
                onAddTapped: {
                    creationSheetDetent = Self.compactCreationDetent
                    coordinator.mainCoordinator.presentAddItem()
                }
            )
            .environment(\.layoutDirection, currentLayoutDirection)
            .padding(.top, 12)
            .padding(.bottom, 6)
        }
        .sheet(item: Bindable(coordinator.mainCoordinator).presentedSheet) { route in
            switch route {
            case .add:
                factory.makeGlobalCreationSheet {
                    coordinator.mainCoordinator.dismissSheet()
                    factory.refreshScheduleTimeline()
                } onTaskSchedulingModeChanged: { isAwanSchedulingEnabled in
                    creationSheetDetent = isAwanSchedulingEnabled
                        ? Self.compactCreationDetent
                        : Self.expandedCreationDetent
                } onGoalFullScreenChanged: { requiresFullScreen in
                    creationSheetDetent = requiresFullScreen
                        ? .large
                        : Self.compactCreationDetent
                }
                .environment(
                    \.layoutDirection,
                    languageManager.currentLanguage == .arabic
                        ? .rightToLeft
                        : .leftToRight
                )
                .environment(
                    \.locale,
                    Locale(identifier: languageManager.currentLanguage.rawValue)
                )
                .id(languageManager.currentLanguage)
                .presentationDetents(
                    [
                        Self.compactCreationDetent,
                        Self.expandedCreationDetent,
                        .large
                    ],
                    selection: $creationSheetDetent
                )
                .presentationDragIndicator(.visible)
            case .home, .calendar, .userInfo, .dailyZones:
                EmptyView()
            }
        }
    }

    private var opaqueTopSafeArea: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                AppColors.screenBackground
                    .frame(height: proxy.safeAreaInsets.top)

                Spacer(minLength: 0)
            }
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

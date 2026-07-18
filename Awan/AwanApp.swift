//
//  AwanApp.swift
//  Awan
//
//  Created by Me3bed on 15/07/2026.
//

import SwiftUI
import SwiftData
import Presentation

@main
struct AwanApp: App {
    @State private var coordinator = AppCoordinator(initialFlow: .auth)
    private let loginViewModel: LoginViewModel
    private let scheduleViewModel: ScheduleTimelineViewModel
    private let makeOtpViewModel: (String) -> OtpVerificationViewModel

    init() {
        let dependencies = AppDependencyContainer()
        loginViewModel = dependencies.resolve(LoginViewModel.self)
        scheduleViewModel = dependencies.resolve(ScheduleTimelineViewModel.self)
        makeOtpViewModel = { email in
            dependencies.resolve(OtpVerificationViewModel.self, argument: email)
        }
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            PresentationFactory().makeAppRootView(
                    loginViewModel: loginViewModel,
                    scheduleViewModel: scheduleViewModel,
                    makeOtpViewModel: makeOtpViewModel
                )
                .environment(coordinator)
        }
        .modelContainer(sharedModelContainer)
    }
}

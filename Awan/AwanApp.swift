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
    @State private var coordinator = AppCoordinator()
    private let scheduleViewModel: ScheduleTimelineViewModel

    init() {
        let dependencies = AppDependencyContainer()
        scheduleViewModel = dependencies.resolve(ScheduleTimelineViewModel.self)
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
//            AppRootView(scheduleViewModel: scheduleViewModel)
//                .environment(coordinator)
            OtpVerificationView()
        }
        .modelContainer(sharedModelContainer)
    }
}

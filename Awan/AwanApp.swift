//
//  AwanApp.swift
//  Awan
//
//  Created by Me3bed on 15/07/2026.
//

import SwiftUI
import SwiftData
import Data
import Presentation

@main
struct AwanApp: App {
    private let presentationFactory: PresentationFactory
    private let sharedModelContainer: ModelContainer

    init() {
        let schema = SchedulingPersistence.schema
        let configuration = ModelConfiguration(
            "AwanScheduling",
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .none,
            cloudKitDatabase: .none
        )
        do {
            sharedModelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Could not create scheduling ModelContainer: \(error)")
        }
        let dependencies = AppDependencyContainer(modelContainer: sharedModelContainer)
        presentationFactory = dependencies.resolve(PresentationFactory.self)
    }

    var body: some Scene {
        WindowGroup {
            presentationFactory.makeAppRootView()
        }
    }
}

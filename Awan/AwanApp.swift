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
    // Change this to `.swiftData` to use the persistent scheduling implementation.
    private static let schedulingImplementation: SchedulingDataSourceImplementation =
        .inMemory(.preview)

    private let presentationFactory: PresentationFactory
    private let sharedModelContainer: ModelContainer?

    init() {
        sharedModelContainer = switch Self.schedulingImplementation {
        case .swiftData:
            Self.makeSchedulingModelContainer()
        case .inMemory:
            nil
        }
        let dependencies = AppDependencyContainer(
            modelContainer: sharedModelContainer,
            schedulingImplementation: Self.schedulingImplementation
        )
        presentationFactory = dependencies.resolve(PresentationFactory.self)
    }

    var body: some Scene {
        WindowGroup {
            presentationFactory.makeAppRootView()
        }
    }

    private static func makeSchedulingModelContainer() -> ModelContainer {
        let schema = SchedulingPersistence.schema
        let configuration = ModelConfiguration(
            "AwanScheduling",
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .none,
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Could not create scheduling ModelContainer: \(error)")
        }
    }
}

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
import Common

@main
struct AwanApp: App {
    @State private var languageManager = LanguageManager()
    @State private var appearanceManager = AppearanceManager()

    private let presentationFactory: PresentationFactory
    private let sharedModelContainer: ModelContainer

    init() {
        sharedModelContainer = Self.makeSchedulingModelContainer()
        let dependencies = AppDependencyContainer(
            modelContainer: sharedModelContainer
        )
        presentationFactory = dependencies.resolve(PresentationFactory.self)
    }

    var body: some Scene {
        WindowGroup {
            presentationFactory.makeAppRootView()
            .environment(languageManager)
            .environment(appearanceManager)
            .environment(\.locale, Locale(identifier: languageManager.currentLanguage.rawValue))
            .environment(\.layoutDirection, languageManager.currentLanguage == .arabic ? .rightToLeft : .leftToRight)
            .preferredColorScheme(appearanceManager.currentAppearance.colorScheme)
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

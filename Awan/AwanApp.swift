//
//  AwanApp.swift
//  Awan
//
//  Created by Me3bed on 15/07/2026.
//

import SwiftUI
import SwiftData
import Presentation
import Common

@main
struct AwanApp: App {
    @State private var languageManager = LanguageManager()
    private let presentationFactory: PresentationFactory

    init() {
        let dependencies = AppDependencyContainer()
        presentationFactory = dependencies.resolve(PresentationFactory.self)
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
            presentationFactory.makeAppRootView()
                .environment(languageManager)
                .environment(\.locale, Locale(identifier: languageManager.currentLanguage.rawValue))
                .environment(\.layoutDirection, languageManager.currentLanguage == .arabic ? .rightToLeft : .leftToRight)
        }
        .modelContainer(sharedModelContainer)
    }
}

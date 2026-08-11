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
import GoogleSignIn
import FirebaseCore

@main
struct AwanApp: App {
    @State private var languageManager = LanguageManager()
    @State private var appearanceManager = AppearanceManager()

    private let presentationFactory: PresentationFactory

    init() {
        sharedModelContainer = Self.makeSchedulingModelContainer()
        let dependencies = AppDependencyContainer(
            modelContainer: sharedModelContainer
        )
        presentationFactory = dependencies.resolve(PresentationFactory.self)
        FirebaseConfigurator.configure()

        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
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
}

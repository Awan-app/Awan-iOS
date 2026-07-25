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

    init() {
        presentationFactory = AppDependencyContainer.shared.resolve(PresentationFactory.self)
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

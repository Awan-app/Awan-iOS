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
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}

@main
struct AwanApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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

//
//  AwanAppShortcuts.swift
//  Awan
//
//  Created by Manona on 25/07/2026.
//

import AppIntents

public struct AwanAppShortcuts: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "Add a task in \(.applicationName)",
                "Create a task in \(.applicationName)",
                "New task in \(.applicationName)"
            ],
            shortTitle: "Add Task",
            systemImageName: "plus"
        )
    }
}

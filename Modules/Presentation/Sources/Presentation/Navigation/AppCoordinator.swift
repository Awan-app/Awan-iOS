//
//  AppCoordinator.swift
//  Awan
//
//  Created by Manona on 15/07/2026.
//

import SwiftUI
import Common

public enum AppFlow: Sendable {
    case auth
    case main
}

@Observable
@MainActor
public final class AppCoordinator {

    public let authCoordinator: AuthCoordinator
    public let mainCoordinator: MainCoordinator
    public private(set) var currentFlow: AppFlow

    public init(initialFlow: AppFlow = .main) {
        self.authCoordinator = AuthCoordinator()
        self.mainCoordinator = MainCoordinator()
        self.currentFlow = initialFlow
    }

    public func switchToMain() {
        currentFlow = .main
    }

    public func switchToAuth() {
        authCoordinator.popToRoot()
        currentFlow = .auth
    }
}

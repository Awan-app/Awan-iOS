//
//  AppCoordinator.swift
//  Awan
//
//  Created by Manona on 15/07/2026.
//

import Observation
import Common

@Observable
@MainActor
public final class AppCoordinator {

    public let authCoordinator: AuthCoordinator
    public let mainCoordinator: MainCoordinator

    public init() {
        self.authCoordinator = AuthCoordinator()
        self.mainCoordinator = MainCoordinator()
    }
}

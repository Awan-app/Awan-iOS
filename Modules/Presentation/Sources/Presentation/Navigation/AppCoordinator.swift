//
//  AppCoordinator.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import Observation
import Common

@Observable
@MainActor
public final class AppCoordinator {

    public let authCoordinator: AuthCoordinator
    public let mainCoordinator: MainCoordinator
    public let onboardingCoordinator: OnboardingCoordinator

    public init() {
        self.authCoordinator = AuthCoordinator()
        self.mainCoordinator = MainCoordinator()
        self.onboardingCoordinator = OnboardingCoordinator()
    }
}

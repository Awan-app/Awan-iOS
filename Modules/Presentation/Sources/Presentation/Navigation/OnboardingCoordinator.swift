//
//  OnboardingCoordinator.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import Common
import SwiftUI

@Observable
@MainActor
public final class OnboardingCoordinator: Coordinating {

    public var path: NavigationPath = NavigationPath()
    public var containerStep: OnboardingRoute = .yourName
    public var presentedSheet: OnboardingRoute?

    public init() {}

    public func push(_ route: AnyHashable) {
        path.append(route)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path = NavigationPath()
    }

    public func present(sheet route: AnyHashable) {
        presentedSheet = route.base as? OnboardingRoute
    }

    public func dismissSheet() {
        presentedSheet = nil
    }

    public func push(_ route: OnboardingRoute) {
        path.append(route)
    }

    public func present(sheet route: OnboardingRoute) {
        presentedSheet = route
    }
}

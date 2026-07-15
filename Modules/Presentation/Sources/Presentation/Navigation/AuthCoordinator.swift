//
//  AuthCoordinator.swift
//  Awan
//
//  Created by Manona on 15/07/2026.
//

import SwiftUI
import Common

@Observable
@MainActor
public final class AuthCoordinator: Coordinating {

    public var path: NavigationPath = NavigationPath()
    public var presentedSheet: AuthRoute?

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
        presentedSheet = route.base as? AuthRoute
    }

    public func dismissSheet() {
        presentedSheet = nil
    }

    public func push(_ route: AuthRoute) {
        path.append(route)
    }

    public func present(sheet route: AuthRoute) {
        presentedSheet = route
    }
}

//
//  Coordinator.swift
//  Awan
//
//  Created by Manona on 15/07/2026.
//

@MainActor
public protocol Coordinating: AnyObject {
    func push(_ route: AnyHashable)
    func pop()
    func popToRoot()
    func present(sheet route: AnyHashable)
    func dismissSheet()
}

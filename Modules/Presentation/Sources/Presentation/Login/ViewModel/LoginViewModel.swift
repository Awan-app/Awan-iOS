//
//  LoginViewModel.swift
//  Awan
//
//  Created by Manona on 18/07/2026.
//

import Foundation
import Observation

public enum LoginState: Equatable, Sendable {
    case idle
    case loading
}

@Observable
@MainActor
public final class LoginViewModel {
    public var email: String = "" {
        didSet {
            if hasAttemptedSubmit {
                hasAttemptedSubmit = false
            }
        }
    }
    
    public private(set) var state: LoginState = .idle
    private var hasAttemptedSubmit: Bool = false
    
    public init() {}
    
    public var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    public var errorMessage: String? {
        guard hasAttemptedSubmit else { return nil }
        if email.isEmpty {
            return "Please enter your email."
        }
        if !isValidEmail {
            return "Please enter a valid email address."
        }
        return nil
    }
    
    public func onSendCodeTapped() {
        hasAttemptedSubmit = true
        
        guard isValidEmail else { return }
        
        state = .loading
        Task {
            try? await Task.sleep(for: .seconds(2))
            if !Task.isCancelled {
                state = .idle
            }
        }
    }
    
    public func onAppleSignInTapped() {
    }
    
    public func onGoogleSignInTapped() {
    }
    
}

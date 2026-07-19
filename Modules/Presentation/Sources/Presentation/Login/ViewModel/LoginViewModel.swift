//
//  LoginViewModel.swift
//  Awan
//
//  Created by Manona on 18/07/2026.
//

import Foundation
import Observation
import Domain
import Network

public enum LoginState: Equatable, Sendable {
    case idle
    case loading
    case rateLimited(secondsRemaining: Int)
    case failure(AuthenticationErrorState)
}


@Observable
@MainActor
public final class LoginViewModel {
    
    public private(set) var state: LoginState = .idle
    public private(set) var hasAttemptedSubmit: Bool = false
    private var isOffline = false
    private var rateLimitTask: Task<Void, Never>?
    private let requestOTPUseCase: RequestOTPUseCase
    private let monitor = NWPathMonitor()
        
    public var email: String = "" {
        didSet {
            if hasAttemptedSubmit {
                hasAttemptedSubmit = false
            }
            if case .failure = state {
                state = .idle
            }
        }
    }
    
    public var isValidEmail: Bool {
        guard let emailRegex = try? Regex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}") else {
            return false
        }
        return email.wholeMatch(of: emailRegex) != nil
    }
    
    public var validationErrorMessage: String? {
        guard hasAttemptedSubmit else { return nil }
        
        if email.isEmpty {
            return "Please enter your email."
        }
        
        if !isValidEmail {
            return "Please enter a valid email address."
        }
        
        return nil
    }

    public var onSuccess: ((String, OTPRequestResult) -> Void)?
        
    public init(requestOTPUseCase: RequestOTPUseCase) {
        self.requestOTPUseCase = requestOTPUseCase
        startNetworkMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    
    public func onSendCodeTapped() {
        hasAttemptedSubmit = true
        guard isValidEmail else { return }
        guard !isOffline else {
            state = .failure(.network)
            return
        }

        let requestedEmail = email
        
        state = .loading
        
        Task {
            do {
                let result = try await requestOTPUseCase.execute(email: requestedEmail)
                if !Task.isCancelled {
                    state = .idle
                    onSuccess?(requestedEmail, result)
                }
            } catch {
                guard !Task.isCancelled else { return }

                if let authError = error as? AuthError,
                   case .rateLimited(let seconds) = authError {
                    triggerRateLimit(seconds: seconds)
                } else {
                    state = .failure(AuthenticationErrorState(error: error))
                }
            }
        }
    }
    
    public func onAppleSignInTapped() {
    }
    
    public func onGoogleSignInTapped() {
    }
    
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let offline = path.status != .satisfied
            Task { @MainActor in
                self?.isOffline = offline
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
        
    public func triggerRateLimit(seconds: Int) {
        rateLimitTask?.cancel()
        state = .rateLimited(secondsRemaining: seconds)
        rateLimitTask = Task {
            var currentSeconds = seconds
            while currentSeconds > 0 {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                currentSeconds -= 1
                state = .rateLimited(secondsRemaining: currentSeconds)
            }
            if !Task.isCancelled {
                state = .idle
            }
        }
    }
    
    public func toggleOffline() {
        isOffline.toggle()
    }
}

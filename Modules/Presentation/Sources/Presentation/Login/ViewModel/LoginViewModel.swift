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
}


@Observable
@MainActor
public final class LoginViewModel {
    
    public private(set) var state: LoginState = .idle
    public private(set) var isOffline: Bool = false
    public private(set) var hasAttemptedSubmit: Bool = false
    private var rateLimitTask: Task<Void, Never>?
    private let requestOTPUseCase: RequestOTPUseCase
    private let monitor = NWPathMonitor()
        
    public var email: String = "" {
        didSet {
            if hasAttemptedSubmit {
                hasAttemptedSubmit = false
            }
        }
    }
    
    public var isValidEmail: Bool {
        guard let emailRegex = try? Regex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}") else {
            return false
        }
        return email.wholeMatch(of: emailRegex) != nil
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
        
    public var isShowingErrorAlert: Bool = false
    public var alertMessage: String = ""
    public var onSuccess: (() -> Void)?
        
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
        guard !isOffline else { return }
        
        state = .loading
        
        Task {
            do {
                let _ = try await requestOTPUseCase.execute(email: email)
                if !Task.isCancelled {
                    state = .idle
                    onSuccess?()
                }
            } catch let error as AuthError {
                if !Task.isCancelled {
                    if case .rateLimited(let seconds) = error {
                        triggerRateLimit(seconds: seconds)
                    } else {
                        state = .idle
                        alertMessage = error.localizedDescription
                        isShowingErrorAlert = true
                    }
                }
            } catch {
                if !Task.isCancelled {
                    state = .idle
                    alertMessage = error.localizedDescription
                    isShowingErrorAlert = true
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

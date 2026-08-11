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
import Common

public enum LoginState: Equatable, Sendable {
    case idle
    case loading
    case rateLimited(secondsRemaining: Int)
    case failure(AuthenticationErrorState)
}

public struct GoogleSignInTokens: Sendable {
    public let idToken: String
    public let accessToken: String
    
    public init(idToken: String, accessToken: String) {
        self.idToken = idToken
        self.accessToken = accessToken
    }
}


@Observable
@MainActor
public final class LoginViewModel {
    
    public private(set) var state: LoginState = .idle
    public private(set) var isGoogleLoading: Bool = false
    public var googleErrorMessage: String? = nil
    public private(set) var hasAttemptedSubmit: Bool = false
    private var isOffline = false
    private var rateLimitTask: Task<Void, Never>?
    private let requestOTPUseCase: RequestOTPUseCase
    private let googleSignInUseCase: GoogleSignInUseCase
    private let googleSignInTokenProvider: @MainActor @Sendable () async throws -> GoogleSignInTokens
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
            return L10n.Login.emptyEmailError
        }
        
        if !isValidEmail {
            return L10n.Login.invalidEmailError
        }
        
        return nil
    }

    public var onSuccess: ((String, OTPRequestResult) -> Void)?
    public var onLoginSuccess: ((VerifyOTPResult) -> Void)?
        
    public init(
        requestOTPUseCase: RequestOTPUseCase,
        googleSignInUseCase: GoogleSignInUseCase,
        googleSignInTokenProvider: @MainActor @Sendable @escaping () async throws -> GoogleSignInTokens
    ) {
        self.requestOTPUseCase = requestOTPUseCase
        self.googleSignInUseCase = googleSignInUseCase
        self.googleSignInTokenProvider = googleSignInTokenProvider
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
        guard !isOffline else {
            googleErrorMessage = L10n.Login.networkOfflineError
            return
        }

        isGoogleLoading = true
        googleErrorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let tokens = try await googleSignInTokenProvider()
                
                if Task.isCancelled { return }
                
                let result = try await googleSignInUseCase.execute(idToken: tokens.idToken, accessToken: tokens.accessToken)
                
                if !Task.isCancelled {
                    isGoogleLoading = false
                    onLoginSuccess?(result)
                }
            } catch {
                guard !Task.isCancelled else { return }
                
                isGoogleLoading = false
                let nsError = error as NSError
                // 8 == GIDSignInError.canceled
                if nsError.domain == "com.google.GIDSignIn" && nsError.code == 8 {
                    return
                }
                
                googleErrorMessage = error.localizedDescription
            }
        }
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

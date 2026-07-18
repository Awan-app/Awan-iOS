//
//  OtpVerificationViewModel.swift
//  Presentation
//

import Foundation
import Observation
import Domain
import Network

@Observable
@MainActor
public final class OtpVerificationViewModel {
    
    public private(set) var state: VerificationState = .idle
    public let email: String
    public var code: String = "" {
        didSet {
            if code.count == 6 && state != .verifying {
                verifyOTP()
            }
        }
    }
    
    public var isShowingErrorAlert: Bool = false
    public var alertMessage: String = ""
    public var onSuccess: (() -> Void)?
    
    private let verifyOTPUseCase: VerifyOTPUseCase
    
    private var deviceId: String {
        return "123e4567-e89b-12d3-a456-426614174000"
    }
    
    public init(email: String, verifyOTPUseCase: VerifyOTPUseCase) {
        self.email = email
        self.verifyOTPUseCase = verifyOTPUseCase
    }
    
    public func verifyOTP() {
        guard code.count == 6 else { return }
        state = .verifying
        
        Task {
            do {
                let result = try await verifyOTPUseCase.execute(email: email, code: code, deviceId: deviceId)
                if !Task.isCancelled {
                    state = .success
                    print("Token stored successfully for user: \(result.user.email)")
                    onSuccess?()
                }
            } catch let error as AuthError {
                if !Task.isCancelled {
                    state = .failure
                    alertMessage = error.localizedDescription
                    isShowingErrorAlert = true
                }
            } catch {
                if !Task.isCancelled {
                    state = .failure
                    alertMessage = error.localizedDescription
                    isShowingErrorAlert = true
                }
            }
        }
    }
    
    public func resetError() {
        state = .idle
        code = ""
        isShowingErrorAlert = false
    }
    
    public func resendCode() {
        // Here you would call requestOTPUseCase again if needed
        state = .idle
        code = ""
    }
}

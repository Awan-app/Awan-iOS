//
//  OtpVerificationViewModel.swift
//  Presentation
//

import Foundation
import Observation
import Domain

@Observable
@MainActor
public final class OtpVerificationViewModel {
    public static let codeLength = 6

    public private(set) var state: OtpVerificationState = .idle
    public let context: OtpVerificationContext
    public private(set) var codeDigits = Array(
        repeating: "",
        count: OtpVerificationViewModel.codeLength
    )
    public private(set) var isResending = false
    public private(set) var resendSecondsRemaining: Int
    public private(set) var inputResetID = 0

    public var code: String {
        codeDigits.joined()
    }

    public var email: String {
        context.email
    }

    public var formattedResendTime: String {
        let minutes = resendSecondsRemaining / 60
        let seconds = resendSecondsRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    public var isResendDisabled: Bool {
        resendSecondsRemaining > 0 || isResending || state == .verifying
    }

    public var isInputDisabled: Bool {
        state == .verifying || isResending
    }

    private let requestOTPUseCase: RequestOTPUseCase
    private let verifyOTPUseCase: VerifyOTPUseCase
    private var resendCountdownTask: Task<Void, Never>?

    public init(
        context: OtpVerificationContext,
        requestOTPUseCase: RequestOTPUseCase,
        verifyOTPUseCase: VerifyOTPUseCase
    ) {
        self.context = context
        self.requestOTPUseCase = requestOTPUseCase
        self.verifyOTPUseCase = verifyOTPUseCase
        resendSecondsRemaining = max(0, context.initialResendSeconds)
        startResendCountdown(seconds: resendSecondsRemaining)
    }

    @discardableResult
    public func updateCodeDigit(_ input: String, at index: Int) -> Int? {
        guard codeDigits.indices.contains(index), !isInputDisabled else {
            return nil
        }

        if case .failure = state {
            state = .idle
        }

        guard !input.isEmpty else {
            codeDigits[index] = ""
            return index
        }

        var enteredDigits = input.filter { $0.isASCII && $0.isNumber }
        guard !enteredDigits.isEmpty else {
            return index
        }

        if !codeDigits[index].isEmpty,
           enteredDigits.count == 2,
           enteredDigits.first == codeDigits[index].first {
            enteredDigits = String(enteredDigits.suffix(1))
        }

        var lastUpdatedIndex = index
        for (offset, digit) in enteredDigits.prefix(codeDigits.count - index).enumerated() {
            lastUpdatedIndex = index + offset
            codeDigits[lastUpdatedIndex] = String(digit)
        }

        if code.count == Self.codeLength {
            verifyOTP()
            return nil
        }

        return nextEmptyDigitIndex(after: lastUpdatedIndex)
    }
    
    public func verifyOTP() {
        guard code.count == Self.codeLength, !isResending else { return }
        state = .verifying
        
        Task {
            do {
                _ = try await verifyOTPUseCase.execute(
                    email: email,
                    code: code
                )
                if !Task.isCancelled {
                    state = .success
                }
            } catch {
                guard !Task.isCancelled else { return }

                state = .failure(AuthenticationErrorState(error: error))
                clearCodeAndRequestFocus()
            }
        }
    }

    public func resendCode() {
        guard !isResendDisabled else { return }

        isResending = true
        state = .idle

        Task {
            do {
                let result = try await requestOTPUseCase.execute(email: email)
                guard !Task.isCancelled else { return }

                isResending = false
                state = .idle
                clearCodeAndRequestFocus()
                startResendCountdown(seconds: result.resendAvailableInSeconds)
            } catch {
                guard !Task.isCancelled else { return }

                isResending = false
                let presentedError = AuthenticationErrorState(error: error)
                state = .failure(presentedError)
                if let authError = error as? AuthError,
                   case .rateLimited(let seconds) = authError {
                    startResendCountdown(
                        seconds: seconds,
                        errorToClearOnCompletion: presentedError
                    )
                }
            }
        }
    }

    private func nextEmptyDigitIndex(after index: Int) -> Int? {
        let nextIndex = index + 1
        if nextIndex < codeDigits.count,
           let emptyIndex = codeDigits[nextIndex...].firstIndex(where: \.isEmpty) {
            return emptyIndex
        }

        return codeDigits.firstIndex(where: \.isEmpty)
    }

    private func clearCodeAndRequestFocus() {
        codeDigits = Array(repeating: "", count: Self.codeLength)
        inputResetID += 1
    }

    private func startResendCountdown(
        seconds: Int,
        errorToClearOnCompletion: AuthenticationErrorState? = nil
    ) {
        resendCountdownTask?.cancel()
        resendSecondsRemaining = max(0, seconds)

        guard resendSecondsRemaining > 0 else {
            clearErrorIfNeeded(errorToClearOnCompletion)
            return
        }

        resendCountdownTask = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(1))
                } catch {
                    return
                }

                guard let self, !Task.isCancelled else { return }
                resendSecondsRemaining = max(0, resendSecondsRemaining - 1)

                guard resendSecondsRemaining == 0 else { continue }
                clearErrorIfNeeded(errorToClearOnCompletion)
                return
            }
        }
    }

    private func clearErrorIfNeeded(_ error: AuthenticationErrorState?) {
        guard let error, state == .failure(error) else { return }
        state = .idle
    }
}

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

    public private(set) var state: VerificationState = .idle
    public let email: String
    public private(set) var codeDigits = Array(
        repeating: "",
        count: OtpVerificationViewModel.codeLength
    )

    public var code: String {
        codeDigits.joined()
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

    @discardableResult
    public func updateCodeDigit(_ input: String, at index: Int) -> Int? {
        guard codeDigits.indices.contains(index), state != .verifying else {
            return nil
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
        clearCode()
        isShowingErrorAlert = false
    }
    
    public func resendCode() {
        // Here you would call requestOTPUseCase again if needed
        state = .idle
        clearCode()
    }

    private func nextEmptyDigitIndex(after index: Int) -> Int? {
        let nextIndex = index + 1
        if nextIndex < codeDigits.count,
           let emptyIndex = codeDigits[nextIndex...].firstIndex(where: \.isEmpty) {
            return emptyIndex
        }

        return codeDigits.firstIndex(where: \.isEmpty)
    }

    private func clearCode() {
        codeDigits = Array(repeating: "", count: Self.codeLength)
    }
}

//
//  OtpVerificationView.swift
//  Presentation
//
//  Created by AndrewMagdy on 17/07/2026.
//

import Common
import SwiftUI

struct OtpVerificationView: View {
    @State private var viewModel: OtpVerificationViewModel

    // One real input for the entire OTP
    @State private var otpText = ""
    @FocusState private var isOtpFocused: Bool

    @Environment(\.colorScheme) private var colorScheme
    @Environment(AppCoordinator.self) private var appCoordinator

    init(viewModel: OtpVerificationViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // Background Gradient
            Group {
                if colorScheme == .dark {
                    AppColors.screenBackground
                } else {
                    LinearGradient(
                        colors: [
                            AppColors.otpTopColor,
                            AppColors.otpWhite
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button header
                HStack(spacing: 12) {
                    AppBackButton(
                        accessibilityLabel: L10n.CalendarScreen.back,
                        onTap: { appCoordinator.authCoordinator.pop() }
                    )
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)

                Spacer()
                    .frame(height: 16)

                AuthCloudLogoView()
                    .padding(.bottom, 24)

                // MARK: - Title

                Text(L10n.OtpVerification.title)
                    .font(AppFonts.title2Black)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.bottom, 12)

                // MARK: - Subtitle

                VStack(spacing: 4) {
                    Text(L10n.OtpVerification.subtitle)
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundColor(AppColors.textSecondary)

                    Text(viewModel.email)
                        .font(AppFonts.subheadlineBold)
                        .foregroundColor(AppColors.accentBlue)
                }
                .padding(.bottom, 32)

                // MARK: - OTP

                VStack(spacing: 8) {
                    otpInput

                    Spacer()
                        .frame(height: 5)

                    verificationStatus
                }
                .padding(.bottom, 16)

                Spacer()

                // MARK: - Bottom Section

                VStack(spacing: 12) {
                    Button {
                        viewModel.resendCode()
                    } label: {
                        if viewModel.resendSecondsRemaining > 0 {
                            Text(
                                L10n.OtpVerification.resendTimer(
                                    viewModel.formattedResendTime
                                )
                            )
                            .font(AppFonts.captionHeavy)
                        } else {
                            HStack(spacing: 6) {
                                Text(L10n.OtpVerification.resend)
                                    .font(AppFonts.captionHeavy)

                                Image(systemName: "arrow.counterclockwise")
                                    .font(AppFonts.captionHeavy)
                            }
                        }
                    }
                    .foregroundColor(
                        viewModel.resendSecondsRemaining > 0
                            ? AppColors.textSecondary
                            : AppColors.accentBlue
                    )
                    .disabled(viewModel.isResendDisabled)
                    .opacity(viewModel.isResending ? 0.5 : 1)

                    Text(L10n.OtpVerification.keypadHint)
                        .font(AppFonts.captionHeavy)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            otpText = viewModel.codeDigits.joined()

            DispatchQueue.main.async {
                isOtpFocused = true
            }
        }
        .onChange(of: otpText) { _, newValue in
            handleOtpChange(newValue)
        }
        .onChange(of: viewModel.inputResetID) {
            otpText = ""

            DispatchQueue.main.async {
                isOtpFocused = true
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: viewModel.state) { _, newState in
            if newState == .success {
                isOtpFocused = false
            } else if newState.isFailure {
                DispatchQueue.main.async {
                    isOtpFocused = true
                }
            }
        }
    }

    // MARK: - OTP Input

    private var otpInput: some View {
        ZStack {
            /*
             One real TextField.

             It owns the keyboard for the entire OTP instead of having
             one UITextField/TextField for every digit.
             */
            TextField("", text: $otpText)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isOtpFocused)
                .autocorrectionDisabled()
                .frame(width: 1, height: 1)
                .opacity(0.01)

            // Visual OTP boxes
            HStack(spacing: 8) {
                ForEach(
                    0..<OtpVerificationViewModel.codeLength,
                    id: \.self
                ) { index in
                    otpDigitBox(at: index)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                guard !viewModel.isInputDisabled else {
                    return
                }

                isOtpFocused = true
            }
        }
        // OTP must always be LTR even when the app is Arabic
        .environment(\.layoutDirection, .leftToRight)
    }

    private func otpDigitBox(at index: Int) -> some View {
        Text(digit(at: index))
            .font(AppFonts.title2Black)
            .foregroundColor(digitTextColor)
            .frame(width: 44, height: 52)
            .background(
                colorScheme == .dark
                    ? AppColors.surface
                    : AppColors.otpWhite
            )
            .cornerRadius(12)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        digitBorderColor,
                        lineWidth: 1.5
                    )
            }
            .accessibilityLabel(
                L10n.OtpVerification.digitAccessibility(index + 1)
            )
            .accessibilityValue(digit(at: index))
    }

    // MARK: - Verification Status

    @ViewBuilder
    private var verificationStatus: some View {
        Group {
            if viewModel.state == .verifying {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(AppColors.accentBlue)

                    HStack(spacing: 0) {
                        Text(L10n.OtpVerification.verified)
                            .font(AppFonts.subheadlineBold)
                            .foregroundColor(AppColors.accentBlue)

                        TypingDotsView()
                            .padding(.leading, 2)
                            .padding(.bottom, 1)
                    }
                }
                .transition(
                    .opacity.combined(
                        with: .scale(scale: 0.95)
                    )
                )

            } else if viewModel.state == .success {
                OtpSuccessAlertView(
                    message: L10n.OtpVerification.verified
                )
                .transition(
                    .opacity.combined(
                        with: .scale(scale: 0.95)
                    )
                )

            } else if let errorState = viewModel.state.error {
                Group {
                    switch errorState {
                    case .network:
                        NetworkErrorView(
                            message: L10n.OtpVerification.offlineError
                        )

                    case .inline(let message):
                        OtpFailureAlertView(
                            message: message
                        )
                    }
                }
                .transition(
                    .opacity.combined(
                        with: .move(edge: .top)
                    )
                )
                .padding(.top, 4)

            } else {
                Spacer()
                    .frame(height: 24)
            }
        }
        .animation(
            .snappy,
            value: viewModel.state
        )
    }

    // MARK: - OTP Handling

    private func handleOtpChange(_ rawValue: String) {
        let normalized = normalizeOtp(rawValue)

        // Strip anything that isn't a digit and enforce max length.
        // Also converts Arabic digits such as ١٢٣ to 123.
        if normalized != rawValue {
            otpText = normalized
            return
        }

        // Keep the TextField focused, but don't accept additional input
        // while the ViewModel is verifying/success/etc.
        if viewModel.isInputDisabled {
            let currentCode = viewModel.codeDigits.joined()

            if otpText != currentCode {
                otpText = currentCode
            }

            return
        }

        syncOtpToViewModel(normalized)
    }

    private func syncOtpToViewModel(_ value: String) {
        let newDigits = value.map { String($0) }

        let currentDigitCount = viewModel.codeDigits
            .prefix { !$0.isEmpty }
            .count

        // Handle deletion / backspace.
        if newDigits.count < currentDigitCount {
            for index in stride(
                from: currentDigitCount - 1,
                through: newDigits.count,
                by: -1
            ) {
                _ = viewModel.handleBackspace(at: index)
            }
        }

        // Handle typing, replacement and OTP autofill/paste.
        let count = min(
            newDigits.count,
            OtpVerificationViewModel.codeLength
        )

        for index in 0..<count {
            let newDigit = newDigits[index]

            guard viewModel.codeDigits[index] != newDigit else {
                continue
            }

            _ = viewModel.updateCodeDigit(
                newDigit,
                at: index
            )
        }
    }

    private func normalizeOtp(_ value: String) -> String {
        let digits = value
            .compactMap { character -> String? in
                guard
                    let number = character.wholeNumberValue,
                    (0...9).contains(number)
                else {
                    return nil
                }

                // Always convert to western 0-9 digits.
                return String(number)
            }
            .joined()

        return String(
            digits.prefix(
                OtpVerificationViewModel.codeLength
            )
        )
    }

    private func digit(at index: Int) -> String {
        guard index < otpText.count else {
            return ""
        }

        let stringIndex = otpText.index(
            otpText.startIndex,
            offsetBy: index
        )

        return String(otpText[stringIndex])
    }

    // MARK: - Styling Helpers

    private var digitTextColor: Color {
        if viewModel.state.isFailure {
            return AppColors.destructive
        }

        if viewModel.state == .success {
            return AppColors.accentGreen
        }

        return AppColors.textPrimary
    }

    private var digitBorderColor: Color {
        if viewModel.state.isFailure {
            return AppColors.destructive
        }

        if viewModel.state == .success {
            return AppColors.accentGreen
        }

        return AppColors.accentBlue
    }
}

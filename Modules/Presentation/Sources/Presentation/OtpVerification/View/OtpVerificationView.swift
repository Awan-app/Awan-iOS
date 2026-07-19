//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 17/07/2026.
//

import Common
import SwiftUI

struct OtpVerificationView: View {
    @State private var viewModel: OtpVerificationViewModel
    @FocusState private var focusedDigitIndex: Int?

    init(viewModel: OtpVerificationViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [AppColors.otpTopColor, AppColors.otpWhite],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer()
                    .frame(height: 48)

                AuthCloudLogoView()
                    .padding(.bottom, 24)

                // Title
                Text("You're in! ☀️")
                    .font(AppFonts.title2Black)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.bottom, 12)

                // Subtitle
                VStack(spacing: 4) {
                    Text("Enter the code we sent to")
                        .font(AppFonts.subheadlineSemibold)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(viewModel.email)
                            .font(AppFonts.subheadlineBold)
                            .foregroundColor(AppColors.accentBlue)
                    
                }
                .padding(.bottom, 32)

                // OTP Fields
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        ForEach(0..<OtpVerificationViewModel.codeLength, id: \.self) { index in
                            TextField(
                                "",
                                text: codeDigitBinding(at: index),
                                prompt: Text("")
                            )
                                .font(AppFonts.title3Black)
                                .foregroundColor(
                                    viewModel.state.isFailure
                                        ? AppColors.destructive : AppColors.textPrimary
                                )
                                .multilineTextAlignment(.center)
                                .textFieldStyle(.plain)
                                .otpKeyboard()
                                .focused($focusedDigitIndex, equals: index)
                                .disabled(viewModel.isInputDisabled)
                                .frame(width: 44, height: 52)
                                .background(AppColors.otpWhite)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            viewModel.state.isFailure
                                                ? AppColors.destructive : AppColors.accentBlue,
                                            lineWidth: 1.5)
                                )
                                .accessibilityLabel("Verification code digit \(index + 1)")
                        }
                    }
                    
                    Spacer().frame(height: 5)
                    // Verification status
                    if viewModel.state == .verifying || viewModel.state == .success {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, AppColors.accentBlue)
                                .font(.system(size: 20, weight: .black))
                                .shadow(color: AppColors.accentBlue.opacity(0.6), radius: 0, x: 0, y: 2)
    
                            HStack(spacing: 0) {
                                Text("Verified — drifting you in")
                                    .font(AppFonts.subheadlineBold)
                                    .foregroundColor(AppColors.accentBlue)
    
                                TypingDotsView()
                                    .padding(.leading, 2)
                                    .padding(.bottom, 1)
                            }
                        }
                    }

                    if let errorState = viewModel.state.error {
                        Group {
                            switch errorState {
                            case .network:
                                NetworkErrorView(
                                    message: "You're offline — reconnect to verify or resend your code."
                                )
                            case .inline(let message):
                                OtpFailureAlertView(message: message)
                            }
                        }
                        .padding(.top, 4)
                    } else {
                        Spacer().frame(height: 24)
                    }
                }
                .padding(.bottom, 16)

                Spacer()

                // Bottom Section
                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.resendCode()
                    }) {
                        if viewModel.resendSecondsRemaining > 0 {
                            Text("RESEND CODE • \(viewModel.formattedResendTime)")
                                .font(AppFonts.captionHeavy)
                        } else {
                            HStack(spacing: 6) {
                                Text("RESEND CODE")
                                    .font(AppFonts.captionHeavy)
                                Image(systemName: "arrow.counterclockwise")
                                    .font(AppFonts.captionHeavy)
                            }
                        }
                    }
                    .foregroundColor(
                        viewModel.resendSecondsRemaining > 0
                            ? AppColors.textSecondary : AppColors.accentBlue
                    )
                    .disabled(viewModel.isResendDisabled)
                    .opacity(viewModel.isResending ? 0.5 : 1)

                    Text("Numeric keypad · auto-submits on the 6th digit")
                        .font(AppFonts.captionHeavy)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            focusedDigitIndex = viewModel.codeDigits.firstIndex(where: \.isEmpty)
        }
        .onChange(of: viewModel.inputResetID) {
            focusedDigitIndex = 0
        }
    }

    private func codeDigitBinding(at index: Int) -> Binding<String> {
        Binding(
            get: { viewModel.codeDigits[index] },
            set: { input in
                focusedDigitIndex = viewModel.updateCodeDigit(input, at: index)
            }
        )
    }
}

private extension View {
    @ViewBuilder
    func otpKeyboard() -> some View {
        self.keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
    }
}

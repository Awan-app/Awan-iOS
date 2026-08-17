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
    @State private var focusedDigitIndex: Int?
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
                        colors: [AppColors.otpTopColor, AppColors.otpWhite],
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

                // Title
                Text(L10n.OtpVerification.title)
                    .font(AppFonts.title2Black)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.bottom, 12)

                // Subtitle
                VStack(spacing: 4) {
                    Text(L10n.OtpVerification.subtitle)
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
                            OtpDigitField(
                                text: viewModel.codeDigits[index],
                                isFocused: focusedDigitIndex == index,
                                isDisabled: viewModel.isInputDisabled,
                                textColor: digitTextColor,
                                onDigitEntered: { input in
                                    focusedDigitIndex = viewModel.updateCodeDigit(input, at: index)
                                },
                                onBackspace: {
                                    focusedDigitIndex = viewModel.handleBackspace(at: index)
                                },
                                onBecameFocused: {
                                    focusedDigitIndex = index
                                }
                            )
                                .frame(width: 44, height: 52)
                                .background(colorScheme == .dark ? AppColors.surface : AppColors.otpWhite)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(digitBorderColor, lineWidth: 1.5)
                                )
                                .accessibilityLabel(L10n.OtpVerification.digitAccessibility(index + 1))
                        }
                    }
                    
                    Spacer().frame(height: 5)

                    // Verification status messages
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
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        } else if viewModel.state == .success {
                            OtpSuccessAlertView(message: L10n.OtpVerification.verified)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        } else if let errorState = viewModel.state.error {
                            Group {
                                switch errorState {
                                case .network:
                                    NetworkErrorView(
                                        message: L10n.OtpVerification.offlineError
                                    )
                                case .inline(let message):
                                    OtpFailureAlertView(message: message)
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .padding(.top, 4)
                        } else {
                            Spacer().frame(height: 24)
                        }
                    }
                    .animation(.snappy, value: viewModel.state)
                }
                .padding(.bottom, 16)

                Spacer()

                // Bottom Section
                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.resendCode()
                    }) {
                        if viewModel.resendSecondsRemaining > 0 {
                            Text(L10n.OtpVerification.resendTimer(viewModel.formattedResendTime))
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
                            ? AppColors.textSecondary : AppColors.accentBlue
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
            focusedDigitIndex = viewModel.codeDigits.firstIndex(where: \.isEmpty)
        }
        .onChange(of: viewModel.inputResetID) {
            focusedDigitIndex = 0
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Styling Helpers

    private var digitTextColor: UIColor {
        if viewModel.state.isFailure {
            return UIColor(AppColors.destructive)
        }
        if viewModel.state == .success {
            return UIColor(AppColors.accentGreen)
        }
        return UIColor(AppColors.textPrimary)
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

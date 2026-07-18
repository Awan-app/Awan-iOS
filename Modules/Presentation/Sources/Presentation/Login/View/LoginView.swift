//
//  LoginView.swift
//  Awan
//
//  Created by Manona on 18/07/2026.
//

import SwiftUI
import Common

struct LoginView: View {
    @State private var viewModel: LoginViewModel
    @State private var isAnimatingLogo = false

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 16)
            logoAndHeaderSection
            formSection
            dividerSection
            socialSection
            Spacer()
            footerSection
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .background(
            LinearGradient(
                stops: [
                    .init(color: AppColors.skyGradientTop, location: 0.0),
                    .init(color: AppColors.skyGradientBottom, location: 0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    private var logoAndHeaderSection: some View {
        VStack(spacing: 16) {
            Image("login-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .offset(y: isAnimatingLogo ? -5 : 5)
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: isAnimatingLogo
                )
                .onAppear {
                    isAnimatingLogo = true
                }

            VStack(spacing: 8) {
                Text("Awan")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.brandDarkBlue)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Your day, drawn as a sky.\nSign in — we'll float you a code.")
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var formSection: some View {
        VStack(spacing: 24) {
            EmailTextField(
                text: $viewModel.email,
                errorMessage: viewModel.errorMessage
            )

            sendCodeButton
        }
    }

    private var sendCodeButton: some View {
        AppButton(
            title: "SEND CODE",
            icon: nil,
            color: AppColors.skyGradientTop.opacity(0.4),
            foregroundColor: AppColors.brandDarkBlue,
            size: .large,
            onTap: {
                triggerHaptic()
                viewModel.onSendCodeTapped()
            }
        )
        .overlay {
            if viewModel.state == .loading {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.skyGradientTop.opacity(0.4))
                ProgressView()
                    .tint(AppColors.brandDarkBlue)
            }
        }
    }

    private var dividerSection: some View {
        HStack(spacing: 12) {
            Capsule()
                .fill(AppColors.brandDarkBlue.opacity(0.3))
                .frame(height: 1.5)
            Text("OR")
                .font(.system(.caption, design: .rounded, weight: .heavy))
                .foregroundStyle(AppColors.brandDarkBlue)
                .kerning(1)
            Capsule()
                .fill(AppColors.brandDarkBlue.opacity(0.3))
                .frame(height: 1.5)
        }
        .padding(.horizontal, 16)
    }

    private var socialSection: some View {
        VStack(spacing: 16) {
            AppButton(
                title: "Sign in with Apple",
                icon: nil,
                iconAsset: "apple-icon",
                color: AppColors.textPrimary,
                foregroundColor: AppColors.onAccent,
                onTap: {
                    triggerHaptic()
                    viewModel.onAppleSignInTapped()
                }
            )
            .accessibilityLabel("Sign in with Apple")

            AppButton(
                title: "Continue with Google",
                icon: nil,
                iconAsset: "google-icon",
                color: AppColors.surface,
                foregroundColor: AppColors.brandDarkBlue,
                borderColor: AppColors.skyGradientTop,
                size: .regular,
                onTap: {
                    triggerHaptic()
                    viewModel.onGoogleSignInTapped()
                }
            )
            .accessibilityLabel("Continue with Google")
        }
    }

    private var footerSection: some View {
        (
            Text("No passwords, ever. By continuing you agree to Awan's ")
                .foregroundStyle(AppColors.textSecondary)
            + Text("Terms")
                .foregroundStyle(AppColors.accentBlue)
            + Text(" & ")
                .foregroundStyle(AppColors.textSecondary)
            + Text("Privacy")
                .foregroundStyle(AppColors.accentBlue)
            + Text(".")
                .foregroundStyle(AppColors.textSecondary)
        )
        .font(.system(.caption, design: .rounded, weight: .heavy))
        .multilineTextAlignment(.center)
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}


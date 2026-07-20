//
//  LoginView.swift
//  Awan
//
//  Created by Manona on 18/07/2026.
//

import SwiftUI
import Common
import UIKit

struct LoginView: View {
    @Environment(AppCoordinator.self) private var appCoordinator
    @State private var viewModel: LoginViewModel
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)
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
        .ignoresSafeArea(.all, edges: .top)
        .onAppear {
            viewModel.onSuccess = { email, result in
                appCoordinator.authCoordinator.push(
                    .otpVerification(
                        OtpVerificationContext(
                            email: email,
                            initialResendSeconds: result.resendAvailableInSeconds
                        )
                    )
                )
            }
        }
    }

    private var logoAndHeaderSection: some View {
        VStack(spacing: 16) {
            AuthCloudLogoView()

            VStack(spacing: 8) {
                Text(L10n.Login.appTitle)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.brandDarkBlue)
                    .fixedSize(horizontal: false, vertical: true)

                Text(L10n.Login.subtitle)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var formSection: some View {
        VStack(spacing: 24) {
            let isRateLimited: Bool = {
                if case .rateLimited = viewModel.state { return true }
                return false
            }()
            let rateLimitMessage: String? = {
                if case .rateLimited(let seconds) = viewModel.state {
                    return "Too many attempts. Try again in \(seconds) s."
                }
                return nil
            }()
            let requestError: AuthenticationErrorState? = {
                guard case .failure(let error) = viewModel.state else { return nil }
                return error
            }()

            EmailTextField(
                text: $viewModel.email,
                errorState: rateLimitMessage.map(AuthenticationErrorState.inline)
                    ?? viewModel.validationErrorMessage.map(AuthenticationErrorState.inline)
                    ?? requestError,
                isRateLimited: isRateLimited
            )

            sendCodeButton
        }
    }

    private var sendCodeButton: some View {
        let isRateLimited: Bool = {
            if case .rateLimited = viewModel.state { return true }
            return false
        }()
        let rateLimitSeconds: Int? = {
            if case .rateLimited(let seconds) = viewModel.state { return seconds }
            return nil
        }()
        let isReady = viewModel.isValidEmail
        let isLoading = viewModel.state == .loading
        let isActive = (isReady || isLoading) && !isRateLimited
        
        let buttonTitle: String = {
            if isLoading { return L10n.Login.sending }
            if let seconds = rateLimitSeconds {
                return L10n.Login.sendCodeTimer(String(format: "%02d", seconds))
            }
            return L10n.Login.sendCode
        }()
        
        return AppButton(
            title: buttonTitle,
            icon: nil,
            color: isActive ? AppColors.accentBlue : AppColors.skyGradientTop.opacity(0.4),
            foregroundColor: isActive ? AppColors.onAccent : AppColors.brandDarkBlue.opacity(0.5),
            shadowColor: isActive ? nil : .clear,
            size: .large,
            onTap: {
                triggerHaptic()
                viewModel.onSendCodeTapped()
            }
        )
        .disabled(isLoading || isRateLimited)
        .overlay {
            if isLoading {
                ProgressView()
                    .tint(AppColors.onAccent)
                    .offset(x: -60)
            }
        }
    }

    private var dividerSection: some View {
        HStack(spacing: 12) {
            Capsule()
                .fill(AppColors.brandDarkBlue.opacity(0.3))
                .frame(height: 1.5)
            Text(L10n.Login.or)
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
                title: L10n.Login.signInWithApple,
                icon: nil,
                iconAsset: "apple-icon",
                color: AppColors.textPrimary,
                foregroundColor: AppColors.onAccent,
                onTap: {
                    triggerHaptic()
                    viewModel.onAppleSignInTapped()
                }
            )
            .accessibilityLabel(L10n.Login.signInWithApple)

            AppButton(
                title: L10n.Login.continueWithGoogle,
                icon: nil,
                iconAsset: "google-icon",
                color: AppColors.surface,
                foregroundColor: AppColors.brandDarkBlue,
                borderColor: AppColors.accentBlue,
                shadowColor: .clear,
                size: .regular,
                useGradient: false,
                onTap: {
                    triggerHaptic()
                    viewModel.onGoogleSignInTapped()
                }
            )
            .accessibilityLabel(L10n.Login.continueWithGoogle)
        }
    }

    private var footerSection: some View {
        (
            Text(L10n.Login.footerTermsPrefix)
                .foregroundStyle(AppColors.textSecondary)
            + Text(L10n.Login.terms)
                .foregroundStyle(AppColors.accentBlue)
            + Text(L10n.Login.and)
                .foregroundStyle(AppColors.textSecondary)
            + Text(L10n.Login.privacy)
                .foregroundStyle(AppColors.accentBlue)
            + Text(L10n.Login.dot)
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

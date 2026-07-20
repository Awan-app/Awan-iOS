//
//  OnboardingWelcomeView.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import SwiftUI
import Common

struct OnboardingWelcomeView: View {
    @Environment(AppCoordinator.self) private var appCoordinator
    @State private var viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)

            mascotSection

            titleSection

            Spacer()

            actionSection
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
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Sections

    @State private var animateMascot = false

    private var mascotSection: some View {
        AuthCloudLogoView()
            .offset(y: animateMascot ? 0 : -30)
            .onAppear {
                withAnimation(.interpolatingSpring(stiffness: 150, damping: 6).delay(0.2)) {
                    animateMascot = true
                }
            }
    }

    private var titleSection: some View {
        VStack(spacing: 12) {
            Text(L10n.Onboarding.welcomeTitle)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.brandDarkBlue)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(L10n.Onboarding.welcomeSubtitle)
                .font(AppFonts.bodySemibold)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var actionSection: some View {
        VStack(spacing: 16) {
            AppButton(
                title: L10n.Onboarding.letsGo,
                icon: nil,
                color: AppColors.accentBlue,
                foregroundColor: AppColors.onAccent,
                size: .large,
                onTap: {
                    appCoordinator.onboardingCoordinator.push(.yourName)
                }
            )

            Button {
                viewModel.skipOnboarding()
            } label: {
                HStack(spacing: 4) {
                    Text(L10n.Onboarding.skipSetup)
                        .font(AppFonts.subheadlineHeavy)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(AppColors.brandDarkBlue)
            }
        }
    }
}

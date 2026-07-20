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
    }

    // MARK: - Sections

    private var mascotSection: some View {
        AuthCloudLogoView()
    }

    private var titleSection: some View {
        VStack(spacing: 12) {
            Text("Hi, I'm Awan.\nThe sky is yours today.")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.brandDarkBlue)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("Tell me a little about your day and I'll\nbuild a schedule that quietly heals itself\nwhen life happens.")
                .font(AppFonts.bodySemibold)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var actionSection: some View {
        VStack(spacing: 16) {
            AppButton(
                title: "LET'S GO",
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
                    Text("Skip setup")
                        .font(AppFonts.subheadlineHeavy)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(AppColors.brandDarkBlue)
            }
        }
    }
}

#Preview {
    OnboardingWelcomeView(viewModel: .preview)
        .environment(AppCoordinator())
}

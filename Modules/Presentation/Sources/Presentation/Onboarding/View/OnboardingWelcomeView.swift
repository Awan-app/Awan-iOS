//
//  OnboardingWelcomeView.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import SwiftUI
import Common
import Domain

struct OnboardingWelcomeView: View {
    @Environment(\.colorScheme) private var colorScheme
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
            Group {
                if colorScheme == .dark {
                    AppColors.screenBackground
                } else {
                    LinearGradient(
                        stops: [
                            .init(color: AppColors.skyGradientTop, location: 0.0),
                            .init(color: AppColors.skyGradientBottom, location: 0.5)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
            .ignoresSafeArea()
        )
    }

    // MARK: - Sections

    private var mascotSection: some View {
        AuthCloudLogoView()
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
        }
    }
}

#Preview {
    OnboardingWelcomeView(
        viewModel: OnboardingViewModel(
            completeOnboardingUseCase: MockCompleteOnboardingUseCase(),
            createOnboardingTemplateUseCase: MockCreateOnboardingTemplateUseCase(),
            manageZoneScheduleUseCase: ManageZoneScheduleUseCaseImpl(),
            fetchCategoriesUseCase: MockFetchCategoriesUseCase()
        )
    )
    .environment(AppCoordinator())
}

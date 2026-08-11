//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 19/07/2026.
//

import SwiftUI
import Common
import Domain

struct AddRealTask: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AppCoordinator.self) private var appCoordinator
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ZStack {
            // 1. Background Layer
            Group {
                if colorScheme == .dark {
                    AppColors.screenBackground
                } else {
                    LinearGradient(
                        stops: [
                            .init(color: AppColors.skyGradientTop, location: 0.0),
                            .init(color: AppColors.skyGradientBottom, location: 0.5),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
            .ignoresSafeArea()

            // 2. Scrollable Content Layer
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        OnboardingStepHeader(
                            currentStep: 6,
                            totalSteps: viewModel.totalSteps,
                            onSkip: { viewModel.skipOnboarding() }
                        )

                        GreetingHeader(
                            name: viewModel.firstName.isEmpty ? "Sam" : viewModel.firstName,
                            zoneCount: viewModel.suggestedZones.count)

                        VStack(spacing: 10) {
                            ForEach(viewModel.suggestedZones) { zone in
                                ZoneRow(zone: zone)
                            }
                        }

                        EmptyStateCard {
                            // Add first task action
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                }

                // 3. Bottom Action Area
                VStack {
                    AppButton(
                        title: L10n.Common.continue,
                        icon: nil,
                        color: AppColors.accentBlue,
                        foregroundColor: AppColors.onAccent,
                        size: .large,
                        onTap: {
                            // Set the hidden container to .notification instantly (no animation),
                            // then let the native NavigationStack pop be the only visible motion.
                            var t = Transaction()
                            t.disablesAnimations = true
                            withTransaction(t) {
                                appCoordinator.onboardingCoordinator.containerStep = .notification
                            }
                            appCoordinator.onboardingCoordinator.pop()
                        }
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

#Preview {
    AddRealTask(
        viewModel: OnboardingViewModel(
            completeOnboardingUseCase: MockCompleteOnboardingUseCase(),
            createOnboardingTemplateUseCase: MockCreateOnboardingTemplateUseCase(),
            manageZoneScheduleUseCase: ManageZoneScheduleUseCaseImpl(),
            fetchCategoriesUseCase: MockFetchCategoriesUseCase()
        )
    )
    .environment(AppCoordinator())
}

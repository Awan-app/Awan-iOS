//
//  OnboardingSuggestedZonesView.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import Common
import SwiftUI

struct OnboardingSuggestedZonesView: View {
    @Environment(AppCoordinator.self) private var appCoordinator
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            OnboardingStepHeader(
                currentStep: 3,
                totalSteps: viewModel.totalSteps,
                onSkip: { viewModel.skipOnboarding() }
            )
            .padding(.horizontal, 24)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    infoTag
                    zonesList
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }

            Spacer(minLength: 0)

            bottomButtons
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .background(
            LinearGradient(
                stops: [
                    .init(color: AppColors.skyGradientTop, location: 0.0),
                    .init(color: AppColors.skyGradientBottom, location: 0.5),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Sections

    private var headerSection: some View {
        Text("Here's a day I sketched for you")
            .font(.system(size: 26, weight: .black, design: .rounded))
            .foregroundStyle(AppColors.brandDarkBlue)
    }

    private var infoTag: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 12, weight: .bold))
            Text("Drag any edge to adjust")
                .font(AppFonts.caption2Bold)
        }
        .foregroundStyle(AppColors.accentBlue)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            AppColors.accentBlue.opacity(0.1),
            in: Capsule()
        )
    }

    private var zonesList: some View {
        VStack(spacing: 10) {
            ForEach(Array(viewModel.suggestedZones.enumerated()), id: \.element.id) { index, zone in
                ZoneCard(zone: zone) {
                    withAnimation(.snappy(duration: 0.25)) {
                        viewModel.removeZone(zone)
                    }
                }

                if index == 1 {
                    AddZoneButton(onTap: {})
                }
            }

            if viewModel.suggestedZones.count <= 1 {
                AddZoneButton(onTap: {})
            }
        }
    }

    private var bottomButtons: some View {
        HStack(spacing: 12) {
            AppButton(
                title: "SET MANUALLY",
                icon: nil,
                color: AppColors.surface,
                foregroundColor: AppColors.brandDarkBlue,
                borderColor: AppColors.accentBlue,
                shadowColor: .clear,
                useGradient: false,
                onTap: {
                    appCoordinator.onboardingCoordinator.push(.taskLength)
                }
            )

            AppButton(
                title: "USE THIS",
                icon: nil,
                color: AppColors.accentBlue,
                foregroundColor: AppColors.onAccent,
                onTap: {
                    appCoordinator.onboardingCoordinator.push(.taskLength)
                }
            )
        }
    }
}

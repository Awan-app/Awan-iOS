//
//  OnboardingWakeSleepView.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import Common
import SwiftUI

struct OnboardingWakeSleepView: View {
    @Environment(AppCoordinator.self) private var appCoordinator
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            OnboardingStepHeader(
                currentStep: 2,
                totalSteps: viewModel.totalSteps,
                onSkip: { viewModel.skipOnboarding() }
            )
            .padding(.horizontal, 24)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    ChangeAnytimeTag()
                    timePickerSection
                    dayPreview
                    midnightNote
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }

            Spacer(minLength: 0)

            continueButton
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
    }

    // MARK: - Sections

    private var headerSection: some View {
        Text("When does your day begin and end?")
            .font(.system(size: 26, weight: .black, design: .rounded))
            .foregroundStyle(AppColors.brandDarkBlue)
    }

    private var timePickerSection: some View {
        VStack(spacing: 12) {
            timeRow(
                icon: "☀️",
                label: "I usually wake up at",
                time: $viewModel.wakeupTime,
                isHighlighted: false
            )

            timeRow(
                icon: "🌙",
                label: "I usually sleep at",
                time: $viewModel.sleepTime,
                isHighlighted: true
            )
        }
    }

    private func timeRow(
        icon: String,
        label: String,
        time: Binding<Date>,
        isHighlighted: Bool
    ) -> some View {
        HStack {
            Text(icon)
                .font(.title3)

            Text(label)
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            DatePicker(
                "",
                selection: time,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .tint(AppColors.accentBlue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            AppColors.surface,
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    isHighlighted
                        ? AppColors.accentBlue
                        : AppColors.outline.opacity(0.08),
                    lineWidth: isHighlighted ? 2 : 1
                )
        }
    }

    private var dayPreview: some View {
        DayPreviewCard(
            wakeupTime: viewModel.wakeupTime,
            sleepTime: viewModel.sleepTime
        )
    }

    private var midnightNote: some View {
        Text("Sleeps past midnight? I'll wrap the night for you.")
            .font(AppFonts.captionHeavy)
            .foregroundStyle(AppColors.textSecondary)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }

    private var continueButton: some View {
        AppButton(
            title: "CONTINUE",
            icon: nil,
            color: AppColors.accentBlue,
            foregroundColor: AppColors.onAccent,
            size: .large,
            onTap: {
                appCoordinator.onboardingCoordinator.push(.suggestedZones)
            }
        )
    }
}

#Preview {
    OnboardingWakeSleepView(viewModel: .preview)
        .environment(AppCoordinator())
}

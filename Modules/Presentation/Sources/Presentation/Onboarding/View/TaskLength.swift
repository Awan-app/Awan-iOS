//
//  SwiftUIView.swift
//  Presentation
//
//  Created by AndrewMagdy on 19/07/2026.
//

import Common
import SwiftUI
import Domain

struct TaskLength: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    let labels = ["10m", "", "", "", "", "1h", "", "", "", "2h", "", "3h"]
    @State private var showValidationError: Bool = false

    var focusDurationText: String {
        if !viewModel.customDurationText.isEmpty, let custom = Int(viewModel.customDurationText), custom >= 10, custom <= 180 {
            if custom < 60 {
                return L10n.Onboarding.durationMinutes(custom)
            } else if custom == 60 {
                return L10n.Onboarding.durationOneHour
            } else if custom % 60 == 0 {
                return L10n.Onboarding.durationHours(custom / 60)
            } else {
                return L10n.Onboarding.durationHoursMinutes(custom / 60, custom % 60)
            }
        }

        let index = min(max(viewModel.focusDurationIndex, 0), OnboardingViewModel.sessionDurations.count - 1)
        let minutes = OnboardingViewModel.sessionDurations[index]
        
        if minutes < 60 {
            return L10n.Onboarding.durationMinutes(minutes)
        } else if minutes == 60 {
            return L10n.Onboarding.durationOneHour
        } else if minutes % 60 == 0 {
            return L10n.Onboarding.durationHours(minutes / 60)
        } else {
            return L10n.Onboarding.durationHoursMinutes(minutes / 60, minutes % 60)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
           // ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    TaskLengthTitleArea()
                    TaskLengthValueDisplay(focusDurationText: focusDurationText)
                    TaskLengthSlider(
                        focusDurationIndex: $viewModel.focusDurationIndex, labels: labels)
                    
                    VStack(spacing: 8) {
                        AppTextField(
                            text: $viewModel.customDurationText,
                            placeholder: "Custom time (min)"
                        )
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 24)
                        
                        if showValidationError {
                            Text("Time must be between 10 and 180 minutes")
                                .foregroundColor(AppColors.destructive)
                                .font(AppFonts.captionHeavy)
                        }
                    }
                    .onChange(of: viewModel.customDurationText) { _, _ in
                        showValidationError = false
                    }

                    TaskLengthExplanation()
                }
                .padding(.bottom, 24)
            //}

            // 3. Floating Bottom Action Area Layer
            VStack {
                AppButton(
                    title: L10n.Common.continue,
                    icon: nil,
                    color: AppColors.accentBlue,
                    foregroundColor: AppColors.onAccent,
                    size: .large,
                    onTap: { handleContinue() }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                Button(action: { onContinue() }) {
                    HStack(spacing: 4) {
                        Text(L10n.Onboarding.skipForNow)
                        Image(systemName: "arrow.right")
                    }
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundColor(AppColors.accentBlue)
                }
                .padding(.vertical, 8)
            }
        }
    }

    private func handleContinue() {
        if !viewModel.customDurationText.isEmpty {
            if let custom = Int(viewModel.customDurationText), custom >= 10, custom <= 180 {
                showValidationError = false
                onContinue()
            } else {
                showValidationError = true
            }
        } else {
            showValidationError = false
            onContinue()
        }
    }
}

private struct TaskLengthExplanation: View {
    var body: some View {
        (Text(L10n.Onboarding.taskLengthExplanationPrefix)
        .font(AppFonts.captionHeavy)
        .foregroundColor(AppColors.textSecondary)
            + Text(L10n.Onboarding.splitIntoSessions)
            .font(AppFonts.captionHeavy)
            .foregroundColor(AppColors.brandDarkBlue))
            .lineSpacing(4)
    }
}

#Preview {
    TaskLength(
        viewModel: OnboardingViewModel(
            completeOnboardingUseCase: MockCompleteOnboardingUseCase(),
            createOnboardingTemplateUseCase: MockCreateOnboardingTemplateUseCase(),
            manageZoneScheduleUseCase: ManageZoneScheduleUseCaseImpl()
        ),
        onContinue: {}
    )
}

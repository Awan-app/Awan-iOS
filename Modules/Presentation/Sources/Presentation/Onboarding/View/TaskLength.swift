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

    @State private var showValidationError: Bool = false

    var dynamicLabels: [String] {
        viewModel.dynamicSessionDurations.map { duration in
            switch duration {
            case 10: return "10m"
            case 60: return "1h"
            case 120: return "2h"
            case 180: return "3h"
            default: return ""
            }
        }
    }

    var focusDurationText: String {
        let minutes = viewModel.selectedDuration
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
                        focusDurationIndex: Binding(
                            get: { viewModel.dynamicSessionDurations.firstIndex(of: viewModel.selectedDuration) ?? 0 },
                            set: { newIndex in
                                let newValue = viewModel.dynamicSessionDurations[newIndex]
                                viewModel.selectedDuration = newValue
                                viewModel.customDurationText = String(newValue)
                                showValidationError = false
                            }
                        ),
                        labels: dynamicLabels
                    )
                    
                    VStack(spacing: 8) {
                        AppTextField(
                            text: $viewModel.customDurationText,
                            placeholder: L10n.Onboarding.customTimePlaceholder
                        )
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 24)
                        
                        if showValidationError {
                            Text(L10n.Onboarding.timeValidationError)
                                .foregroundColor(AppColors.destructive)
                                .font(AppFonts.captionHeavy)
                        }
                    }
                    .onChange(of: viewModel.customDurationText) { _, newValue in
                        if let custom = Int(newValue) {
                            if custom >= 10 && custom <= 180 {
                                viewModel.selectedDuration = custom
                                showValidationError = false
                            }
                        }
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
                viewModel.selectedDuration = custom
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
            manageZoneScheduleUseCase: ManageZoneScheduleUseCaseImpl(),
            fetchCategoriesUseCase: MockFetchCategoriesUseCase()
        ),
        onContinue: {}
    )
}

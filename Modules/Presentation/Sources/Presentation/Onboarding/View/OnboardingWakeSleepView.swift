//
//  OnboardingWakeSleepView.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import Common
import SwiftUI
import Domain

struct OnboardingWakeSleepView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    ChangeAnytimeTag()
                    timePickerSection
                    if viewModel.wakeSleepTimesAreEqual {
                        sameTimeWarning
                    }
                    if !viewModel.wakeSleepTimesAreEqual && viewModel.availableHours < 9 {
                        shortDayWarning
                    }
                    dayPreview
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
            }

            Spacer(minLength: 0)

            continueButton
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        Text(L10n.Onboarding.wakeSleepTitle)
            .font(.system(size: 26, weight: .black, design: .rounded))
            .foregroundStyle(AppColors.brandDarkBlue)
    }

    private var sameTimeWarning: some View {
        inlineWarning(text: L10n.Onboarding.wakeSleepSameTimeError)
    }

    private var shortDayWarning: some View {
        inlineWarning(text: L10n.Onboarding.shortActiveDayWarning)
    }

    private func inlineWarning(text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .bold))
            Text(text)
                .font(AppFonts.caption2Bold)
        }
        .foregroundStyle(AppColors.warning)
        .padding(.horizontal, 12)
        //.padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            AppColors.warning.opacity(0.1),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var timePickerSection: some View {
        VStack(spacing: 12) {
            timeRow(
                icon: "☀️",
                label: L10n.Onboarding.wakeLabel,
                time: $viewModel.wakeupTime,
                isHighlighted: false
            )

            timeRow(
                icon: "🌙",
                label: L10n.Onboarding.sleepLabel,
                time: $viewModel.sleepTime,
                isHighlighted: false
            ).padding(.top,10)
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

    private var continueButton: some View {
        let isDisabled = viewModel.wakeSleepTimesAreEqual || viewModel.availableHours < 9
        return AppButton(
            title: L10n.Common.continue,
            icon: nil,
            color: AppColors.accentBlue,
            foregroundColor: AppColors.onAccent,
            size: .large,
            onTap: {
                guard !isDisabled else { return }
                onContinue()
            }
        )
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

#Preview {
    OnboardingWakeSleepView(
        viewModel: OnboardingViewModel(
            completeOnboardingUseCase: MockCompleteOnboardingUseCase(),
            createOnboardingTemplateUseCase: MockCreateOnboardingTemplateUseCase(),
            manageZoneScheduleUseCase: ManageZoneScheduleUseCaseImpl()
        ),
        onContinue: {}
    )
}

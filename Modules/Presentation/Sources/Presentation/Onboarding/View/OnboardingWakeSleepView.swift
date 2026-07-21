//
//  OnboardingWakeSleepView.swift
//  Awan
//
//  Created by Me3bed on 20/07/2026.
//

import Common
import SwiftUI

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
    }

    // MARK: - Sections

    private var headerSection: some View {
        Text(L10n.Onboarding.wakeSleepTitle)
            .font(.system(size: 26, weight: .black, design: .rounded))
            .foregroundStyle(AppColors.brandDarkBlue)
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
        Text(L10n.Onboarding.midnightNote)
            .font(AppFonts.captionHeavy)
            .foregroundStyle(AppColors.textSecondary)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }

    private var continueButton: some View {
        AppButton(
            title: L10n.Common.continue,
            icon: nil,
            color: AppColors.accentBlue,
            foregroundColor: AppColors.onAccent,
            size: .large,
            onTap: {
                onContinue()
            }
        )
    }
}

#Preview {
    OnboardingWakeSleepView(viewModel: .preview, onContinue: {})
}

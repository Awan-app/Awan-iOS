import Common
import SwiftUI
import Domain

private struct ReasonItem: Identifiable {
    let id = UUID()
    let boldPart: String
    let mutedPart: String
}

struct NotificationView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    let onSkipNotifications: () -> Void
    private var reasons: [ReasonItem] {
        [
            ReasonItem(boldPart: L10n.Onboarding.notificationReason1Bold, mutedPart: L10n.Onboarding.notificationReason1Muted),
            ReasonItem(boldPart: L10n.Onboarding.notificationReason2Bold, mutedPart: L10n.Onboarding.notificationReason2Muted),
            ReasonItem(boldPart: L10n.Onboarding.notificationReason3Bold, mutedPart: L10n.Onboarding.notificationReason3Muted),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(alignment: .center, spacing: 20) {
                AuthCloudLogoView()

                Text(L10n.Onboarding.notificationTitle)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(AppColors.brandDarkBlue)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                NotificationPreviewCard(
                    appName: L10n.Onboarding.notificationPreviewAppName,
                    timestamp: L10n.Onboarding.notificationPreviewTimestamp,
                    message: L10n.Onboarding.notificationPreviewMessage
                )
                .padding(.horizontal, 8)

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(reasons) { reason in
                        NudgeReasonRow(
                            boldPart: reason.boldPart, mutedPart: reason.mutedPart)
                    }
                }
                .padding(.horizontal, 16)

                VStack(spacing: 12) {
                    Text(L10n.Onboarding.notificationSystemDisclaimer)
                        .font(AppFonts.caption2Bold)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)

                    AppButton(
                        title: L10n.Onboarding.turnOnNudges,
                        icon: nil,
                        color: AppColors.accentBlue,
                        foregroundColor: AppColors.onAccent,
                        size: .large,
                        isLoading: viewModel.isCompleting,
                        onTap: {
                            onContinue()
                        }
                    )
                    .disabled(viewModel.isCompleting)

                    Button(action: { onSkipNotifications() }) {
                        HStack(spacing: 4) {
                            Text(L10n.Onboarding.skipForNow)
                            Image(systemName: "arrow.right")
                        }
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundColor(AppColors.accentBlue)
                    }
                    .disabled(viewModel.isCompleting)
                    .padding(.vertical, 8)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)

            Spacer(minLength: 16)
        }
    }
}

#Preview {
    NotificationView(
        viewModel: OnboardingViewModel(
            completeOnboardingUseCase: MockCompleteOnboardingUseCase(),
            createOnboardingTemplateUseCase: MockCreateOnboardingTemplateUseCase(),
            manageZoneScheduleUseCase: ManageZoneScheduleUseCaseImpl(),
            fetchCategoriesUseCase: MockFetchCategoriesUseCase()
        ),
        onContinue: {},
        onSkipNotifications: {}
    )
}

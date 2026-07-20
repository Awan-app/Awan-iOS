import Common
import SwiftUI

private struct ReasonItem: Identifiable {
    let id = UUID()
    let boldPart: String
    let mutedPart: String
}


struct NotificationView: View {
    @Environment(AppCoordinator.self) private var appCoordinator
    @Bindable var viewModel: OnboardingViewModel
    private let reasons: [ReasonItem] = [
        ReasonItem(boldPart: "Only when a block starts", mutedPart: "— no buzzing all day."),
        ReasonItem(boldPart: "Stay in flow", mutedPart: "— gentle reminders to keep you on track."),
        ReasonItem(boldPart: "Customizable", mutedPart: "— you can always turn these off later."),
    ]

    var body: some View {
        ZStack {
            AppColors.skyGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(alignment: .center, spacing: 32) {
                        OnboardingStepHeader(
                            currentStep: 7,
                            totalSteps: viewModel.totalSteps,
                            onSkip: { viewModel.skipOnboarding() }
                        )

                        AuthCloudLogoView()
                            .padding(.top, 8)

                        Text("Want a gentle nudge\nwhen it's time?")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(AppColors.brandDarkBlue)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)

                        NotificationPreviewCard(
                            appName: "Awan",
                            timestamp: "now",
                            message: "Work starts in 5 min — Design review is up first."
                        )
                        .padding(.horizontal, 8)

                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(reasons) { reason in
                                NudgeReasonRow(
                                    boldPart: reason.boldPart, mutedPart: reason.mutedPart)
                            }
                        }
                        .padding(.horizontal, 16)

                        VStack(spacing: 16) {
                            Text("The system will ask next — this is just so you know why.")
                                .font(AppFonts.caption2Bold)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)

                            AppButton(
                                title: "TURN ON NUDGES",
                                icon: nil,
                                color: AppColors.accentBlue,
                                foregroundColor: AppColors.onAccent,
                                size: .large,
                                onTap: {
                                    viewModel.notificationsEnabled = true
                                    viewModel.completeOnboarding()
                                }
                            )

                            Button(action: {
                                viewModel.notificationsEnabled = false
                                viewModel.completeOnboarding()
                            }) {
                                HStack(spacing: 4) {
                                    Text("Not now")
                                }
                                .font(AppFonts.subheadlineHeavy)
                                .foregroundColor(AppColors.accentBlue)
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

//#Preview {
//    NotificationView()
//        .environment(OnboardingCoordinator())
//}

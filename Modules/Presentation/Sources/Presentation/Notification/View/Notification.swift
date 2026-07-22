import Common
import SwiftUI

private struct ReasonItem: Identifiable {
    let id = UUID()
    let boldPart: String
    let mutedPart: String
}

struct NotificationView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    let onSkipNotifications: () -> Void
    private let reasons: [ReasonItem] = [
        ReasonItem(boldPart: "Only when a block starts", mutedPart: "— no buzzing all day."),
        ReasonItem(boldPart: "Stay in flow", mutedPart: "— gentle reminders to keep you on track."),
        ReasonItem(boldPart: "Customizable", mutedPart: "— you can always turn these off later."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(alignment: .center, spacing: 20) {
                AuthCloudLogoView()

                Text("Want a gentle nudge\nwhen it's time?")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(AppColors.brandDarkBlue)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                NotificationPreviewCard(
                    appName: "Awan",
                    timestamp: "now",
                    message: "Work starts in 5 min — Design review is up first."
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
                            onContinue()
                        }
                    )
                    .disabled(viewModel.isCompleting)

                    Button(action: {
                        onSkipNotifications()
                    }) {
                        HStack(spacing: 4) {
                            Text("Not now")
                        }
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundColor(AppColors.accentBlue)
                    }
                    .disabled(viewModel.isCompleting)
                    .padding(.vertical, 4)
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
        viewModel: .preview,
        onContinue: {},
        onSkipNotifications: {}
    )
}

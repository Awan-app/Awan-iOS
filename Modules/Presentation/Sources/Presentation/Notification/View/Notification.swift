import Common
import SwiftUI

private struct ReasonItem: Identifiable {
    let id = UUID()
    let boldPart: String
    let mutedPart: String
}


struct NotificationView: View {

    
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
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 32) {

                        AuthCloudLogoView()
                            .padding(.top, 40)

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
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }

                VStack(spacing: 16) {
                    Text("The system will ask next — this is just so you know why.")
                        .font(AppFonts.caption2Bold)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    OnboardingContinueButton(
                        title: "TURN ON NUDGES",
                        action: {
                            // Request permission action
                        }
                    )

                    SkipForNowLink(title: "Not now") {
                        // Skip action
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .padding(.top, 16)
            }
        }
    }
}

#Preview {
    NotificationView()
}

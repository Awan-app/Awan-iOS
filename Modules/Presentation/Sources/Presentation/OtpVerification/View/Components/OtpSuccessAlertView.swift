import SwiftUI
import Common

struct OtpSuccessAlertView: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppColors.accentGreen)

            Text(message)
                .font(AppFonts.captionHeavy)
                .foregroundColor(AppColors.accentGreen)
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    OtpSuccessAlertView(message: "Verified — drifting you in")
}

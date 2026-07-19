import SwiftUI
import Common

struct OtpFailureAlertView: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(AppColors.destructive)
            
            Text(message)
                .font(AppFonts.captionHeavy)
                .foregroundColor(AppColors.destructive)
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    OtpFailureAlertView(message: "The code is incorrect. Please try again.")
}

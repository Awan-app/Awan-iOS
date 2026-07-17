import SwiftUI
import Common

struct OtpFailureAlertView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(AppColors.destructive)
            
            Text("The code is incorrect. Please try again.")
                .font(AppFonts.captionHeavy)
                .foregroundColor(AppColors.destructive)
        }
    }
}

#Preview {
    OtpFailureAlertView()
}

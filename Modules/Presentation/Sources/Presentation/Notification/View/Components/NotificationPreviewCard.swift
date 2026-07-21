import SwiftUI
import Common

struct NotificationPreviewCard: View {
    let appName: String
    let timestamp: String
    let message: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppColors.accentBlue)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "bell.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                )
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(appName)
                        .font(AppFonts.captionHeavy)
                        .foregroundColor(AppColors.brandDarkBlue)
                    Text("·")
                        .font(AppFonts.captionHeavy)
                        .foregroundColor(AppColors.textSecondary)
                    Text(timestamp)
                        .font(AppFonts.caption2Bold)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Text(message)
                    .font(AppFonts.caption2Bold)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: AppColors.shadow.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

#Preview {
    ZStack {
        AppColors.screenBackground.ignoresSafeArea()
        NotificationPreviewCard(
            appName: "Awan",
            timestamp: "now",
            message: "Work starts in 5 min — Design review is up first."
        )
        .padding()
    }
}

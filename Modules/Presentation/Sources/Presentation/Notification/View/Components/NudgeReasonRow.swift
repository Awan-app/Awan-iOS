import SwiftUI
import Common

struct NudgeReasonRow: View {
    let boldPart: String
    let mutedPart: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(AppColors.accentBlue.opacity(0.12))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.accentBlue)
                )
            
            // Text combined
            (Text(boldPart)
                .font(AppFonts.bodyBold)
                .foregroundColor(AppColors.brandDarkBlue)
             + Text(" " + mutedPart)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary))
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 4)
            
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    ZStack {
        AppColors.screenBackground.ignoresSafeArea()
        NudgeReasonRow(
            boldPart: "Only when a block starts",
            mutedPart: "— no buzzing all day."
        )
        .padding()
    }
}

import SwiftUI
import Common

struct UserInfoMascotMessageSection: View {
    let firstName: String
    
    var body: some View {
        HStack(spacing: 12) {
            
            Text(L10n.UserInfo.mascotMessage(firstName))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.vertical, 10)
    }
}

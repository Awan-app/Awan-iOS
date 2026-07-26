import SwiftUI
import Common

struct UserInfoFieldRow: View {
    let title: String
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.brandDarkBlue)
                .frame(width: 100, alignment: .leading)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .tint(AppColors.accentBlue)
        }
        .padding(.vertical, 16)
    }
}

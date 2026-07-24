import Common
import SwiftUI

struct QuickAddSeparator: View {
    var body: some View {
        HStack(spacing: 14) {
            Rectangle()
                .fill(AppColors.accentBlue.opacity(0.4))
                .frame(height: 1.5)

            Text(L10n.Home.orSeparator.uppercased())
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.accentBlue)

            Rectangle()
                .fill(AppColors.accentBlue.opacity(0.4))
                .frame(height: 1.5)
        }
        .padding(.vertical, 4)
    }
}

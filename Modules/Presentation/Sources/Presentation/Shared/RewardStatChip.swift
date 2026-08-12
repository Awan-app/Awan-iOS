import Common
import SwiftUI

struct RewardStatChip: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 14),
            borderColor: color.opacity(0.55),
            depthColor: color.opacity(0.72),
            depthOffset: 4,
            contentInsets: EdgeInsets(
                top: 9,
                leading: 14,
                bottom: 9,
                trailing: 14
            )
        ) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(AppFonts.statSymbol)
                Text(value)
                    .font(AppFonts.headlineBlack)
            }
            .foregroundStyle(color)
        }
    }
}

#Preview("Reward Stat Chip Light") {
    RewardStatChip(icon: "star.fill", value: "120", color: AppColors.reward)
        .padding()
        .background(AppColors.screenBackground)
}

#Preview("Reward Stat Chip Dark") {
    RewardStatChip(icon: "star.fill", value: "120", color: AppColors.reward)
        .padding()
        .background(AppColors.screenBackground)
        .preferredColorScheme(.dark)
}

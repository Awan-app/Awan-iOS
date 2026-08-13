import Common
import SwiftUI

struct RewardStatChip: View {
    let icon: String
    let value: String
    let color: Color
    var isCompact = false

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: isCompact ? 12 : 14),
            borderColor: color.opacity(0.55),
            depthColor: color.opacity(0.72),
            depthOffset: isCompact ? 3 : 4,
            contentInsets: EdgeInsets(
                top: isCompact ? 6 : 9,
                leading: isCompact ? 10 : 14,
                bottom: isCompact ? 6 : 9,
                trailing: isCompact ? 10 : 14
            )
        ) {
            HStack(spacing: isCompact ? 6 : 8) {
                Image(systemName: icon)
                    .font(
                        isCompact
                            ? AppFonts.captionIconBlack
                            : AppFonts.statSymbol
                    )
                Text(value)
                    .font(
                        isCompact
                            ? AppFonts.subheadlineBlack
                            : AppFonts.headlineBlack
                    )
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

import Common
import SwiftUI

struct ProfileNavigationButton: View {
    let icon: String
    let title: String
    let subtitle: String?
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(AppFonts.progressSymbol)
                    .foregroundStyle(color)
                    .frame(width: 42, height: 42)
                    .background(
                        color.opacity(0.12),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(AppFonts.headlineBlack)
                        .foregroundStyle(AppColors.textPrimary)

                    if let subtitle {
                        Text(subtitle)
                            .font(AppFonts.subheadlineSemibold)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(2)
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.forward")
                    .font(AppFonts.captionIconBlack)
                    .foregroundStyle(color)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: subtitle == nil ? 62 : 76)
            .contentShape(Rectangle())
        }
        .buttonStyle(
            AppDepthButtonStyle(
                shape: .roundedRectangle(cornerRadius: 20),
                surfaceColor: AppColors.surface,
                borderColor: color.opacity(0.30),
                depthColor: color.opacity(0.38),
                depthOffset: 5
            )
        )
        .accessibilityHint(subtitle ?? "")
    }
}

#Preview("Profile Navigation Light") {
    ProfileNavigationButton(
        icon: "gearshape.fill",
        title: "Settings",
        subtitle: "Personalize Awan",
        color: AppColors.accentBlue,
        action: {}
    )
    .padding()
    .background(AppColors.screenBackground)
}

#Preview("Profile Navigation Dark") {
    ProfileNavigationButton(
        icon: "gearshape.fill",
        title: "Settings",
        subtitle: "Personalize Awan",
        color: AppColors.accentBlue,
        action: {}
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}

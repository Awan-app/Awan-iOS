import Common
import SwiftUI

struct ProfileMenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
}

struct ProfileMenuCard: View {
    let items: [ProfileMenuItem]

    var body: some View {
        DepthCardContainer {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    Button(action: item.action) {
                        HStack(spacing: 8) {
                            Image(systemName: item.icon)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(item.color)
                                .frame(width: 26, alignment: .center)

                            Text(item.title)
                                .font(AppFonts.subheadlineBold)
                                .foregroundStyle(AppColors.textPrimary)
                                .multilineTextAlignment(.leading)

                            Spacer(minLength: 8)

                            Image(systemName: "chevron.forward")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                        }
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < items.count - 1 {
                        Rectangle()
                            .fill(AppColors.divider)
                            .frame(height: 1)
                            .padding(.leading, 38)
                            .padding(.vertical, 6)
                    }
                }
            }
        }
    }
}

#Preview("Profile Menu Light") {
    ProfileMenuCard(items: [
        ProfileMenuItem(
            icon: "slider.horizontal.3",
            title: "Personalization",
            color: AppColors.accentBlue,
            action: {}
        ),
        ProfileMenuItem(
            icon: "circle.lefthalf.filled",
            title: "Language & Appearance",
            color: AppColors.warning,
            action: {}
        ),
        ProfileMenuItem(
            icon: "info.circle.fill",
            title: "About Awan",
            color: AppColors.accentGreen,
            action: {}
        )
    ])
    .padding()
    .background(AppColors.screenBackground)
}

#Preview("Profile Menu Dark") {
    ProfileMenuCard(items: [
        ProfileMenuItem(
            icon: "slider.horizontal.3",
            title: "Personalization",
            color: AppColors.accentBlue,
            action: {}
        ),
        ProfileMenuItem(
            icon: "circle.lefthalf.filled",
            title: "Language & Appearance",
            color: AppColors.warning,
            action: {}
        )
    ])
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}

import Common
import SwiftUI

struct ProfileHeroCard: View {
    let avatarImage: Image?
    let name: String
    let email: String
    let points: Int
    let streak: Int
    let maxStreak: Int
    let onEdit: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 26),
            surfaceColor: AppColors.surface,
            borderColor: AppColors.accentBlue.opacity(0.24),
            depthColor: AppColors.accentBlueDepth.opacity(0.32),
            depthOffset: 6,
            contentInsets: EdgeInsets()
        ) {
            VStack(spacing: 20) {
                identity

                ProfileProgressSection(
                    points: points,
                    streak: streak,
                    maxStreak: maxStreak
                )
            }
            .padding(18)
        }
    }

    @ViewBuilder
    private var identity: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    ProfileAvatarView(image: avatarImage, size: 56)
                    Spacer()
                    ProfileEditButton(onTap: onEdit)
                }

                ProfileNameEmailView(name: name, email: email)
            }
        } else {
            HStack(spacing: 16) {
                ProfileAvatarView(image: avatarImage, size: 56)
                ProfileNameEmailView(name: name, email: email)
                Spacer(minLength: 4)
                ProfileEditButton(onTap: onEdit)
            }
        }
    }
}

#Preview("Profile Hero Light") {
    ProfileHeroCard(
        avatarImage: nil,
        name: "Awan User",
        email: "hello@awan.app",
        points: 1_240,
        streak: 6,
        maxStreak: 18,
        onEdit: {}
    )
    .padding()
    .background(AppColors.screenBackground)
    .environment(LanguageManager())
}

#Preview("Profile Hero Dark") {
    ProfileHeroCard(
        avatarImage: nil,
        name: "Awan User",
        email: "hello@awan.app",
        points: 1_240,
        streak: 6,
        maxStreak: 18,
        onEdit: {}
    )
    .padding()
    .background(AppColors.screenBackground)
    .environment(LanguageManager())
    .preferredColorScheme(.dark)
}

import Common
import SwiftUI

struct FramedProfileAvatar<Avatar: View>: View {
    let frameImageURL: String?
    let size: CGFloat
    let framedAvatarScale: CGFloat
    let borderColor: Color
    let borderWidth: CGFloat
    let avatar: Avatar

    init(
        frameImageURL: String?,
        size: CGFloat,
        framedAvatarScale: CGFloat = 0.7,
        borderColor: Color = AppColors.accentBlue.opacity(0.25),
        borderWidth: CGFloat = 2.5,
        @ViewBuilder avatar: () -> Avatar
    ) {
        self.frameImageURL = frameImageURL
        self.size = size
        self.framedAvatarScale = framedAvatarScale
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.avatar = avatar()
    }

    var body: some View {
        ZStack {
            avatar
                .frame(width: avatarSize, height: avatarSize)
                .clipShape(Circle())
                .overlay {
                    if !hasFrame {
                        Circle()
                            .stroke(borderColor, lineWidth: borderWidth)
                    }
                }

            if let frameImageURL, !frameImageURL.isEmpty {
                AppRemoteImage(urlString: frameImageURL, contentMode: .fit) {
                    Color.clear
                }
                .frame(width: size, height: size)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
        }
        .frame(width: size, height: size)
    }

    private var hasFrame: Bool {
        guard let frameImageURL else { return false }
        return !frameImageURL.isEmpty
    }

    private var avatarSize: CGFloat {
        hasFrame ? size * framedAvatarScale : size
    }
}

#Preview("Framed Avatar") {
    FramedProfileAvatar(
        frameImageURL: nil,
        size: 80
    ) {
        Image(systemName: "person.fill")
            .font(.system(size: 36, weight: .semibold))
            .foregroundStyle(AppColors.accentBlue)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.accentBlue.opacity(0.10))
    }
    .padding()
    .background(AppColors.screenBackground)
}

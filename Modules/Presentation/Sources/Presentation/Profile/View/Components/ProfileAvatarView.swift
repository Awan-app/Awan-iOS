//
//  ProfileAvatarView.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Common

struct ProfileAvatarView: View {
    let imageUrl: String?
    let frameImageUrl: String?
    var size: CGFloat = 56

    init(
        imageUrl: String?,
        frameImageUrl: String? = nil,
        size: CGFloat = 56
    ) {
        self.imageUrl = imageUrl
        self.frameImageUrl = frameImageUrl
        self.size = size
    }

    var body: some View {
        FramedProfileAvatar(
            frameImageURL: frameImageUrl,
            size: size
        ) {
            AppRemoteImage(urlString: imageUrl, contentMode: .fill) {
                placeholder
            }
        }
    }
    private var placeholder: some View {
        Image(systemName: "person.fill")
            .font(.system(size: 28, weight: .semibold))
            .foregroundStyle(AppColors.accentBlue)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.accentBlue.opacity(0.10))
    }
}


#Preview {
    ProfileAvatarView(imageUrl: nil)
        .padding()
}

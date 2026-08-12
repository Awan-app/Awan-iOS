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
    var size: CGFloat = 56

    var body: some View {
        AppRemoteImage(urlString: imageUrl, contentMode: .fill) {
            placeholder
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(AppColors.accentBlue.opacity(0.25), lineWidth: 2.5)
        )
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

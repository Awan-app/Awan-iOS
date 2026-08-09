//
//  ProfileAvatarView.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Common

struct ProfileAvatarView: View {
    let image: Image?
    var size: CGFloat = 56

    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AppColors.accentBlue)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.accentBlue.opacity(0.10))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(AppColors.accentBlue.opacity(0.25), lineWidth: 2.5)
        )
    }
}


#Preview {
    ProfileAvatarView(image: nil)
        .padding()
}

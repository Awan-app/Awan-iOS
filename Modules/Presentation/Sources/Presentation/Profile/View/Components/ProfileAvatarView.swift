//
//  ProfileAvatarView.swift
//  Presentation
//

import SwiftUI
import Common

struct ProfileAvatarView: View {
    let image: Image?

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
        .frame(width: 56, height: 56)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(AppColors.accentBlue.opacity(0.25), lineWidth: 2.5)
        )
    }
}

//
//  PersonalInfoCard.swift
//  Presentation
//
//  Created by AndrewMagdy on 21/07/2026.
//

import SwiftUI
import Common
import Domain

// MARK: - PersonalInfoCard

struct PersonalInfoCard: View {
    let imageUrl: String?
    let name: String
    let email: String
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(title: L10n.Profile.personalInfo)

            DepthCardContainer {
                HStack(spacing: 14) {
                    ProfileAvatarView(imageUrl: imageUrl)
                    ProfileNameEmailView(name: name, email: email)
                    Spacer(minLength: 8)
                    ProfileEditButton(onTap: onEdit)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("PersonalInfoCard – Light") {
    PersonalInfoCard(
        imageUrl: nil,
        name: UserProfile.mock.firstName,
        email: UserProfile.mock.email,
        onEdit: {}
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.light)
}

#Preview("PersonalInfoCard – Dark") {
    PersonalInfoCard(
        imageUrl: nil,
        name: UserProfile.mock.firstName,
        email: UserProfile.mock.email,
        onEdit: {}
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}

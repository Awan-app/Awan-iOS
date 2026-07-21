//
//  PersonalInfoCard.swift
//  Presentation
//

import SwiftUI
import Common

// MARK: - PersonalInfoCard

struct PersonalInfoCard: View {
    let avatarImage: Image?
    let name: String
    let email: String
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderLabel(title: "PERSONAL INFO")

            DepthCardContainer {
                HStack(spacing: 14) {
                    ProfileAvatarView(image: avatarImage)
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
        avatarImage: nil,
        name: "Sam Rivera",
        email: "sam@awan.app",
        onEdit: {}
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.light)
}

#Preview("PersonalInfoCard – Dark") {
    PersonalInfoCard(
        avatarImage: nil,
        name: "Sam Rivera",
        email: "sam@awan.app",
        onEdit: {}
    )
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}

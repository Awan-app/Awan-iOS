//import SwiftUI
//import Common
//import PhotosUI
//
//struct UserInfoProfilePictureSection: View {
//    @Binding var selectedPhotoItem: PhotosPickerItem?
//    @Binding var profileImage: Image?
//    var viewModel: UserInfoViewModel
//    
//    var body: some View {
//        ZStack(alignment: .bottomTrailing) {
//            ZStack {
//                if let frameUrl = viewModel.frameImageUrl {
//                    AppRemoteImage(urlString: frameUrl, contentMode: .fit) {
//                        Color.clear
//                    }
//                    .frame(width: 160, height: 160)
//                }
//
//                Group {
//                    if let profileImage {
//                        profileImage
//                            .resizable()
//                            .scaledToFill()
//                    } else if let imageUrl = viewModel.profilePictureUrl {
//                        AppRemoteImage(urlString: imageUrl, contentMode: .fill) {
//                            Image("user-avatar")
//                                .resizable()
//                                .scaledToFill()
//                        }
//                    } else {
//                        Image("user-avatar")
//                            .resizable()
//                            .scaledToFill()
//                    }
//                }
//                .frame(width: 100, height: 100)
//                .clipShape(Circle())
//                .overlay(
//                    Circle()
//                        .stroke(Color.white, lineWidth: viewModel.frameImageUrl == nil ? 4 : 0)
//                )
//            }
//            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
//            
//            PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
//                Circle()
//                    .fill(Color.white)
//                    .frame(width: 32, height: 32)
//                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
//                    .overlay(
//                        Image(systemName: "pencil")
//                            .font(.system(size: 14, weight: .bold))
//                            .foregroundColor(AppColors.accentBlue)
//                    )
//            }
//            .offset(x: -4, y: -4)
//        }
//        .onChange(of: selectedPhotoItem) { _, newItem in
//            Task {
//                if let data = try? await newItem?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
//                    profileImage = Image(uiImage: uiImage)
//                    if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
//                        viewModel.profileImageData = jpegData
//                        viewModel.profileImageMimeType = "image/jpeg"
//                        viewModel.profileImageFileName = "profile.jpg"
//                    }
//                }
//            }
//        }
//    }
//}
import SwiftUI
import Common
import PhotosUI
import UIKit

struct UserInfoProfilePictureSection: View {
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var profileImage: Image?

    var viewModel: UserInfoViewModel

    // MARK: - Sizes

    private let frameSize: CGFloat = 160
    private let framedAvatarSize: CGFloat = 118
    private let normalAvatarSize: CGFloat = 145
    private let editButtonSize: CGFloat = 40

    private var hasFrame: Bool {
        guard let url = viewModel.frameImageUrl else {
            return false
        }

        return !url.isEmpty
    }

    private var displayedAvatarSize: CGFloat {
        hasFrame ? framedAvatarSize : normalAvatarSize
    }

    var body: some View {
        ZStack {
            // Backend frame stays behind the profile picture.
            //
            // This also works if the checkerboard/center of the
            // backend image is not actually transparent.
            if let frameImageUrl = viewModel.frameImageUrl,
               !frameImageUrl.isEmpty {
                AppRemoteImage(
                    urlString: frameImageUrl,
                    contentMode: .fit
                ) {
                    Color.clear
                }
                .frame(
                    width: frameSize,
                    height: frameSize
                )
            }

            // The selected or existing profile image is centered
            // inside the opening of the frame.
            profileAvatar
                .frame(
                    width: displayedAvatarSize,
                    height: displayedAvatarSize
                )
                .clipShape(Circle())
                .overlay {
                    // Only show the white border when no special
                    // backend frame is available.
                    if !hasFrame {
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    }
                }
        }
        .frame(
            width: frameSize,
            height: frameSize
        )
        .overlay(alignment: .bottomTrailing) {
            editPhotoButton
                .offset(x: 2, y: 2)
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                await handleSelectedPhoto(newItem)
            }
        }
    }

    // MARK: - Profile Avatar

    @ViewBuilder
    private var profileAvatar: some View {
        if let profileImage {
            profileImage
                .resizable()
                .scaledToFill()

        } else if let imageUrl = viewModel.profilePictureUrl,
                  !imageUrl.isEmpty {
            AppRemoteImage(
                urlString: imageUrl,
                contentMode: .fill
            ) {
                defaultAvatar
            }

        } else {
            defaultAvatar
        }
    }

    private var defaultAvatar: some View {
        Image("user-avatar")
            .resizable()
            .scaledToFill()
    }

    // MARK: - Edit Button

    private var editPhotoButton: some View {
        PhotosPicker(
            selection: $selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Circle()
                .fill(Color.white)
                .frame(
                    width: editButtonSize,
                    height: editButtonSize
                )
                .shadow(
                    color: Color.black.opacity(0.15),
                    radius: 5,
                    x: 0,
                    y: 2
                )
                .overlay {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.accentBlue)
                }
        }
    }

    // MARK: - Handle Selected Photo

    private func handleSelectedPhoto(
        _ newItem: PhotosPickerItem?
    ) async {
        guard let newItem else {
            return
        }

        guard let data = try? await newItem.loadTransferable(
            type: Data.self
        ),
        let uiImage = UIImage(data: data) else {
            return
        }

        let jpegData = uiImage.jpegData(compressionQuality: 0.8)

        await MainActor.run {
            profileImage = Image(uiImage: uiImage)
            viewModel.profileImageData = jpegData
            viewModel.profileImageMimeType = "image/jpeg"
            viewModel.profileImageFileName = "profile.jpg"
        }
    }
}

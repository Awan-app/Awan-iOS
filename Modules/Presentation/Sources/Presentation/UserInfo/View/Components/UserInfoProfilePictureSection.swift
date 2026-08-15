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
    private let editButtonSize: CGFloat = 40

    var body: some View {
        FramedProfileAvatar(
            frameImageURL: viewModel.frameImageUrl,
            size: frameSize,
            borderColor: AppColors.onAccent,
            borderWidth: 4
        ) {
            profileAvatar
        }
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

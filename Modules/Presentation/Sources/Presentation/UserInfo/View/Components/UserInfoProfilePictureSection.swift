import SwiftUI
import Common
import PhotosUI

struct UserInfoProfilePictureSection: View {
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var profileImage: Image?
    var viewModel: UserInfoViewModel
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let profileImage {
                    profileImage
                        .resizable()
                        .scaledToFill()
                } else if let imageUrl = viewModel.profilePictureUrl {
                    AppRemoteImage(urlString: imageUrl, contentMode: .fill) {
                        Image("user-avatar")
                            .resizable()
                            .scaledToFill()
                    }
                } else {
                    Image("user-avatar")
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 32, height: 32)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .overlay(
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.accentBlue)
                    )
            }
            .offset(x: -4, y: -4)
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                    profileImage = Image(uiImage: uiImage)
                    if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
                        viewModel.profileImageData = jpegData
                        viewModel.profileImageMimeType = "image/jpeg"
                        viewModel.profileImageFileName = "profile.jpg"
                    }
                }
            }
        }
    }
}

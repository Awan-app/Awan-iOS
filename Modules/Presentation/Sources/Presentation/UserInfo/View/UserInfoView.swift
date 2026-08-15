import SwiftUI
import Common
import PhotosUI
import Domain

public struct UserInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppearanceManager.self) private var appearanceManager
    @Environment(LanguageManager.self) private var languageManager
    
    @State private var viewModel: UserInfoViewModel
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileImage: Image?
    
    public init(viewModel: UserInfoViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 24) {
                
                Text(L10n.UserInfo.subtitle)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .padding(.top, 40)

            UserInfoProfilePictureSection(
                selectedPhotoItem: $selectedPhotoItem,
                profileImage: $profileImage,
                viewModel: viewModel
            )
            
            UserInfoPersonalInfoSection(viewModel: viewModel)
            
            UserInfoMascotMessageSection(firstName: viewModel.firstName)
            
            UserInfoActionButtonsSection(viewModel: viewModel, dismiss: dismiss)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 40)
        .background(AppColors.screenBackground.ignoresSafeArea())
        .preferredColorScheme(appearanceManager.currentAppearance.colorScheme)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.body.weight(.semibold))
                        .foregroundColor(viewModel.isSaving ? AppColors.textSecondary : AppColors.accentBlue)
                        .environment(\.layoutDirection, languageManager.currentLanguage == .arabic ? .rightToLeft : .leftToRight)
                }
                .disabled(viewModel.isSaving)
            }
            ToolbarItem(placement: .principal) {
                Text(L10n.UserInfo.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.brandDarkBlue)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                GifImageView("Animated AWAN mascot")
                    .frame(width: 65, height: 65)
            }
        }
        .task {
            viewModel.observeUserProfile()
            await viewModel.refreshEquippedFrame()
        }
        
        // MARK: - Full-screen loading overlay
        if viewModel.isSaving {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .allowsHitTesting(true)
                .overlay {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(1.5)
                        .padding(24)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                .transition(.opacity)
                .zIndex(2)
        }
        
        // MARK: - Toast overlay
        if viewModel.showToast, let message = viewModel.toastMessage {
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: viewModel.toastIsSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text(message)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(viewModel.toastIsSuccess ? AppColors.accentGreen : Color.red)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                viewModel.showToast = false
                            }
                            if viewModel.toastIsSuccess {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    dismiss()
                                }
                            }
                        }
                    }
            }
            .zIndex(3)
        }
        }
    }
}

#Preview {
    UserInfoView(
        viewModel: UserInfoViewModel(
            getUserProfileUseCase: MockGetUserProfileUseCase(),
            updateUserProfileUseCase: MockUpdateUserProfileUseCase(),
            updateProfilePictureUseCase: MockUpdateProfilePictureUseCase()
        )
    )
        .environment(AppearanceManager())
        .environment(LanguageManager())
}

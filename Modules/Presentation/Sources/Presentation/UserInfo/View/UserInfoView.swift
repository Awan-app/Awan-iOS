import SwiftUI
import Common
import PhotosUI

public struct UserInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppearanceManager.self) private var appearanceManager
    @Environment(LanguageManager.self) private var languageManager
    
    @Bindable var viewModel: UserInfoViewModel
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileImage: Image?
    
    public init(viewModel: UserInfoViewModel = UserInfoViewModel()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            
            Text(L10n.UserInfo.subtitle)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .padding(.top, 40)

            profilePictureSection
            personalInfoSection
            mascotMessageSection
            actionButtonsSection
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 40)
        .background(AppColors.screenBackground.ignoresSafeArea())
        .preferredColorScheme(appearanceManager.currentAppearance.colorScheme)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.body.weight(.semibold))
                        .foregroundColor(AppColors.accentBlue)
                        .environment(\.layoutDirection, languageManager.currentLanguage == .arabic ? .rightToLeft : .leftToRight)
                }
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
    }
    
    // MARK: - Sections
    
    private var profilePictureSection: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let profileImage {
                    profileImage
                        .resizable()
                        .scaledToFill()
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
                    viewModel.profileImageData = data
                }
            }
        }
    }
    
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.UserInfo.personalInfo)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(AppColors.brandDarkBlue)
                .kerning(1.2)
            
            AppCard {
                VStack(spacing: 0) {
                    UserInfoFieldRow(
                        title: L10n.UserInfo.firstName,
                        text: $viewModel.firstName,
                        placeholder: "e.g. Sam"
                    )
                    Divider().padding(.leading, 120)
                    
                    UserInfoFieldRow(
                        title: L10n.UserInfo.lastName,
                        text: $viewModel.lastName,
                        placeholder: "e.g. Rivera"
                    )
                    Divider().padding(.leading, 120)
                    
                    // Email (Non-editable)
                    HStack {
                        Text(L10n.UserInfo.email)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.brandDarkBlue)
                            .frame(width: 100, alignment: .leading)
                        
                        Text(viewModel.email)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Spacer()
                        
                        Image(systemName: "lock")
                            .font(.title2)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.vertical, 16)
                    
                    Divider().padding(.leading, 120)
                    
                    // Date of Birth
                    HStack {
                        Text(L10n.UserInfo.dateOfBirth)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.brandDarkBlue)
                            .frame(width: 100, alignment: .leading)
                        
                        Text(viewModel.dateOfBirth.formatted(.dateTime.day().month(.wide).year()))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .overlay(
                                DatePicker(
                                    "",
                                    selection: $viewModel.dateOfBirth,
                                    displayedComponents: .date
                                )
                                .labelsHidden()
                                .colorMultiply(.clear)
                            )
                        
                        Spacer()
                        
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(AppColors.accentBlue)
                    }
                    .padding(.vertical, 16)
                }
            }
        }
    }
    
    private var mascotMessageSection: some View {
        HStack(spacing: 12) {
            Image("info-cloud")
                .resizable()
                .scaledToFit()
                .frame(width: 65, height: 65)
            
            Text(L10n.UserInfo.mascotMessage(viewModel.firstName))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.vertical, 10)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            AppButton(
                title: L10n.Schedule.saveChanges,
                icon: "checkmark.circle.fill",
                color: AppColors.accentBlue,
                foregroundColor: AppColors.onAccent,
                onTap: {
                    Task {
                        await viewModel.saveChanges()
                        dismiss()
                    }
                }
            )
            
            Button(L10n.Common.cancel) {
                dismiss()
            }
            .font(AppFonts.bodyBold)
            .foregroundColor(AppColors.accentBlue)
        }
    }
}

// MARK: - Field Row Component

fileprivate struct UserInfoFieldRow: View {
    let title: String
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.brandDarkBlue)
                .frame(width: 100, alignment: .leading)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .tint(AppColors.accentBlue)
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    UserInfoView()
        .environment(AppearanceManager())
        .environment(LanguageManager())
}

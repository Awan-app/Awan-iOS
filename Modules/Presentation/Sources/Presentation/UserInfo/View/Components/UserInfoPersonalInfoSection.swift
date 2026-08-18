import SwiftUI
import Common

struct UserInfoPersonalInfoSection: View {
    @Bindable var viewModel: UserInfoViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeaderLabel(title: L10n.UserInfo.personalInfo)
            
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
                }
            }
        }
    }
}

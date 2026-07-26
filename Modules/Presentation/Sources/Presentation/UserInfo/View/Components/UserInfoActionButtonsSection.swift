import SwiftUI
import Common

struct UserInfoActionButtonsSection: View {
    var viewModel: UserInfoViewModel
    let dismiss: DismissAction
    
    var body: some View {
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
            .disabled(viewModel.isSaveDisabled)
            .opacity(viewModel.isSaveDisabled ? 0.5 : 1.0)
        }
    }
}

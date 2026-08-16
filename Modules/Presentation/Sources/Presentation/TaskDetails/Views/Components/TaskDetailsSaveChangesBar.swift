import Common
import SwiftUI

struct TaskDetailsSaveChangesBar: View {
    let canSave: Bool
    let isSaving: Bool
    let onSave: () -> Void

    var body: some View {
        AppButton(
            title: L10n.TaskDetails.saveChanges,
            icon: "checkmark.circle.fill",
            color: canSave
                ? AppColors.accentBlue
                : AppColors.buttonDisabled,
            isLoading: isSaving,
            onTap: onSave
        )
        .disabled(!canSave)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 14)
        .background(AppColors.sheetBackground)
        .overlay(alignment: .top) {
            Divider()
                .foregroundStyle(AppColors.divider)
        }
    }
}

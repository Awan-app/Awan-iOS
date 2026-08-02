import Common
import SwiftUI

struct DailyZonesBottomAction: View {
    let viewModel: DailyZonesViewModel

    @ViewBuilder
    var body: some View {
        let canEdit = viewModel.state.mode == .weekly
            ? viewModel.selectedTemplate != nil
            : viewModel.selectedOverride != nil
        if canEdit {
            AppButton(
                title: viewModel.state.mode == .weekly
                    ? L10n.Templates.saveTemplate
                    : L10n.Templates.saveChanges,
                icon: "checkmark.circle.fill",
                color: viewModel.state.isDirty ? AppColors.accentBlue : AppColors.buttonDisabled,
                foregroundColor: AppColors.onAccent,
                onTap: { viewModel.send(.save) }
            )
            .disabled(!viewModel.state.isDirty || viewModel.state.isSaving)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 16)
            .background(AppColors.screenBackground.ignoresSafeArea(edges: .bottom))
        }
    }
}

import Common
import SwiftUI

public struct DailyZonesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppearanceManager.self) private var appearanceManager
    private let viewModel: DailyZonesViewModel

    public init(viewModel: DailyZonesViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            DailyZonesScreenHeader {
                viewModel.send(.requestDismiss)
            }

            switch viewModel.state.phase {
            case .idle, .loading:
                DailyZonesLoadingView()
            case .failure(let message):
                DailyZonesFailureView(message: message) {
                    viewModel.send(.retry)
                }
            case .content:
                DailyZonesContentView(viewModel: viewModel)
                DailyZonesBottomAction(viewModel: viewModel)
            }
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .tabBar)
        .navigationBarHidden(true)
        .task { viewModel.send(.appeared) }
        .onChange(of: viewModel.state.shouldDismiss) { _, shouldDismiss in
            guard shouldDismiss else { return }
            dismiss()
            viewModel.send(.dismissCompleted)
        }
        .sheet(item: sheetBinding) { sheet in
            Group {
                switch sheet {
                case .createTemplate:
                    TemplateCreationSheet(viewModel: viewModel, isEditingOverride: false)
                case .editTemplate:
                    TemplateDetailsSheet(viewModel: viewModel)
                case .editOverride:
                    TemplateCreationSheet(viewModel: viewModel, isEditingOverride: true)
                case .zoneEditor:
                    DailyZoneEditorSheet(viewModel: viewModel)
                }
            }
            .preferredColorScheme(appearanceManager.currentAppearance.colorScheme)
        }
        .confirmationDialog(
            dialogTitle,
            isPresented: dialogBinding,
            titleVisibility: .visible,
            actions: dialogActions,
            message: { Text(dialogMessage) }
        )
        .alert(L10n.Templates.unableToUpdate, isPresented: errorBinding) {
            Button(L10n.Common.gotIt) { viewModel.send(.dismissError) }
        } message: {
            Text(viewModel.state.errorMessage ?? L10n.Common.pleaseTryAgain)
        }
    }

    private var sheetBinding: Binding<DailyZonesSheet?> {
        Binding(
            get: { viewModel.state.sheet },
            set: { value in if value == nil { viewModel.send(.dismissSheet) } }
        )
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.errorMessage != nil },
            set: { if !$0 { viewModel.send(.dismissError) } }
        )
    }

    private var dialogBinding: Binding<Bool> {
        Binding(
            get: {
                guard let dialog = viewModel.state.dialog else { return false }
                switch dialog {
                case .deleteZone, .deleteOverride:
                    return false
                default:
                    return true
                }
            },
            set: { if !$0 { viewModel.send(.cancelDialog) } }
        )
    }

    private var dialogTitle: String {
        switch viewModel.state.dialog {
        case .deleteZone(let zone): L10n.Templates.deleteZoneConfirmation(zone.name)
        case .applyZoneEdit: L10n.Templates.applyZoneChangesConfirmation
        case .unsavedChanges: L10n.Templates.unsavedChanges
        case .deleteTemplate(let template): L10n.Templates.deleteTemplateConfirmation(template.name)
        case .deleteOverride: L10n.Templates.useWeeklyRoutineConfirmation
        case nil: L10n.Templates.confirm
        }
    }

    private var dialogMessage: String {
        switch viewModel.state.dialog {
        case .deleteZone:
            L10n.Templates.zoneRemovalMessage
        case .applyZoneEdit(let original, let updated):
            viewModel.zoneEditSummary(original: original, updated: updated)
        case .unsavedChanges:
            L10n.Templates.unsavedZoneChangesMessage
        case .deleteTemplate:
            L10n.Templates.deleteTemplateMessage
        case .deleteOverride:
            L10n.Templates.useWeeklyRoutineMessage
        case nil:
            ""
        }
    }

    @ViewBuilder
    private func dialogActions() -> some View {
        switch viewModel.state.dialog {
        case .unsavedChanges:
            Button(L10n.Common.save) { viewModel.send(.confirmDialog) }
            Button(L10n.Templates.discardChanges, role: .destructive) {
                viewModel.send(.discardAndContinue)
            }
            Button(L10n.Common.cancel, role: .cancel) { viewModel.send(.cancelDialog) }
        case .deleteZone, .deleteTemplate, .deleteOverride:
            Button(L10n.Templates.delete, role: .destructive) { viewModel.send(.confirmDialog) }
            Button(L10n.Common.cancel, role: .cancel) { viewModel.send(.cancelDialog) }
        case .applyZoneEdit:
            Button(L10n.Templates.applyChanges) { viewModel.send(.confirmDialog) }
            Button(L10n.Common.cancel, role: .cancel) { viewModel.send(.cancelDialog) }
        case nil:
            EmptyView()
        }
    }
}

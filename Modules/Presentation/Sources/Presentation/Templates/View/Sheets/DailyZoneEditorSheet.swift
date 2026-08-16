import Common
import SwiftUI

struct DailyZoneEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: DailyZonesViewModel
    @State private var isCreateCategorySheetPresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let form = viewModel.state.zoneForm {
                        ZoneSheetHeader(
                            iconName: form.editingID == nil ? "plus.square.fill" : "square.and.pencil",
                            title: form.editingID == nil ? L10n.Onboarding.addZoneTitle : L10n.Onboarding.editZone,
                            selectedColor: paletteColor(form.selectedColorIndex),
                            bounceValue: form.selectedColorIndex
                        )

                        AppCard {
                            VStack(alignment: .leading, spacing: 20) {
                                ZoneNameField(
                                    zoneName: Binding(
                                        get: { viewModel.state.zoneForm?.name ?? "" },
                                        set: { viewModel.send(.setZoneName($0)) }
                                    )
                                )
                                ZoneColorPicker(
                                    selectedColorIndex: Binding(
                                        get: { viewModel.state.zoneForm?.selectedColorIndex ?? 0 },
                                        set: { viewModel.send(.setZoneColor($0)) }
                                    )
                                )
                                CategoryPickerField(
                                    categories: viewModel.state.categories,
                                    selectedCategoryID: Binding(
                                        get: { viewModel.state.zoneForm?.selectedCategoryID },
                                        set: { viewModel.send(.setZoneCategory($0)) }
                                    ),
                                    errorMessage: viewModel.state.categoryErrorMessage,
                                    allowsCreation: true,
                                    onRetry: { viewModel.send(.retryCategories) },
                                    onCreateRequested: {
                                        isCreateCategorySheetPresented = true
                                    }
                                )
                                ZoneTimePickers(
                                    startTime: Binding(
                                        get: { viewModel.state.zoneForm?.startTime ?? Date() },
                                        set: { viewModel.send(.setZoneStart($0)) }
                                    ),
                                    endTime: Binding(
                                        get: { viewModel.state.zoneForm?.endTime ?? Date() },
                                        set: { viewModel.send(.setZoneEnd($0)) }
                                    ),
                                    isHorizontal: form.editingID != nil,
                                    onChange: {}
                                )
                            }
                        }

                        ZoneWarningsView(
                            showCategoryRequired: !viewModel.state.categories.contains {
                                $0.id == form.selectedCategoryID
                            },
                            showOverlapError: form.overlapMessage != nil,
                            showOutsideHoursWarning: form.outsideHoursWarning
                        )
                    }

                    AppButton(
                        title: viewModel.state.zoneForm?.editingID == nil
                            ? L10n.Onboarding.addZone
                            : L10n.Onboarding.saveZone,
                        icon: "checkmark.circle.fill",
                        color: isValid ? AppColors.accentBlue : AppColors.buttonDisabled,
                        foregroundColor: AppColors.onAccent,
                        onTap: { viewModel.send(.submitZoneForm) }
                    )
                    .disabled(!isValid)
                }
                .padding(20)
            }
            .background(AppColors.sheetBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.close) {
                        viewModel.send(.dismissSheet)
                        dismiss()
                    }
                    .font(AppFonts.bodyBold)
                }
            }
        }
        .sheet(isPresented: $isCreateCategorySheetPresented) {
            CategoryAddSheet(
                onSave: { name in
                    await viewModel.createCategory(name: name)
                    if viewModel.state.categoryErrorMessage == nil {
                        isCreateCategorySheetPresented = false
                    }
                },
                onDismiss: {
                    isCreateCategorySheetPresented = false
                }
            )
            .presentationDetents([.height(320)])
            .presentationDragIndicator(.visible)
        }
    }

    private var isValid: Bool {
        guard let form = viewModel.state.zoneForm else { return false }
        return form.isValid && viewModel.state.categories.contains {
            $0.id == form.selectedCategoryID
        }
    }

    private func paletteColor(_ index: Int) -> Color {
        guard ZoneColorPalette.colors.indices.contains(index) else { return AppColors.runtimeFallback }
        let color = ZoneColorPalette.colors[index]
        return Color(red: color.red, green: color.green, blue: color.blue)
    }
}

import Common
import SwiftUI

struct CategoryCreationSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: DailyZonesViewModel

    @State private var name = ""
    private let initialSelectedCategoryID: UUID?

    init(viewModel: DailyZonesViewModel) {
        self.viewModel = viewModel
        initialSelectedCategoryID = viewModel.state.zoneForm?.selectedCategoryID
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ZoneSheetHeader(
                        iconName: "square.grid.2x2.fill",
                        title: L10n.Categories.create,
                        selectedColor: AppColors.accentBlue,
                        bounceValue: name.count
                    )

                    AppDepthSurface(
                        shape: .roundedRectangle(cornerRadius: 20),
                        contentInsets: EdgeInsets(
                            top: 18,
                            leading: 18,
                            bottom: 20,
                            trailing: 18
                        )
                    ) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(L10n.Categories.newName)
                                .font(AppFonts.subheadlineHeavy)
                                .foregroundStyle(AppColors.textPrimary)

                            AppTextField(
                                text: $name,
                                placeholder: L10n.Categories.newName
                            )
                        }
                    }

                    if let errorMessage = viewModel.state.categoryErrorMessage {
                        Text(errorMessage)
                            .font(AppFonts.caption2Bold)
                            .foregroundStyle(AppColors.warning)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(
                                AppColors.warningSurface,
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                    }

                    AppButton(
                        title: L10n.Categories.create,
                        icon: "plus.circle.fill",
                        color: isValid ? AppColors.accentBlue : AppColors.buttonDisabled,
                        foregroundColor: AppColors.onAccent,
                        onTap: {
                            viewModel.send(.createCategory(name))
                        }
                    )
                    .disabled(!isValid || viewModel.state.isCreatingCategory)
                }
                .padding(20)
            }
            .background(AppColors.sheetBackground.ignoresSafeArea())
            .navigationTitle(L10n.Categories.create)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.close) { dismiss() }
                        .font(AppFonts.bodyBold)
                }
            }
        }
        .onChange(of: viewModel.state.zoneForm?.selectedCategoryID) { _, selectedID in
            guard let selectedID, selectedID != initialSelectedCategoryID else { return }
            dismiss()
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

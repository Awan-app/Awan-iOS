import Common
import Domain
import SwiftUI

struct CategoryEditSheet: View {
    let category: TaskCategory
    let onSave: (String) async -> Void
    let onDismiss: () -> Void

    @State private var name: String
    @State private var isSaving = false
    @State private var localError: String?

    init(
        category: TaskCategory,
        onSave: @escaping (String) async -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.category = category
        self.onSave = onSave
        self.onDismiss = onDismiss
        _name = State(initialValue: category.name)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ZoneSheetHeader(
                    iconName: "pencil.circle.fill",
                    title: L10n.Categories.edit,
                    selectedColor: AppColors.accentBlue,
                    bounceValue: name.count
                )
                .padding(.top, 12)

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

                if let localError {
                    Text(localError)
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
                    title: L10n.Categories.save,
                    icon: "checkmark.circle.fill",
                    color: isValid ? AppColors.accentBlue : AppColors.buttonDisabled,
                    foregroundColor: AppColors.onAccent,
                    onTap: {
                        Task {
                            isSaving = true
                            await onSave(name)
                            isSaving = false
                        }
                    }
                )
                .disabled(!isValid || isSaving)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(alignment: .top) {
            AppCloudsHorizon(height: 220)
                .frame(maxWidth: .infinity)
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
    }

    private var isValid: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed != category.name
    }
}

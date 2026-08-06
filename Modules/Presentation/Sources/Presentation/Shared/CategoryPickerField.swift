import Common
import Domain
import SwiftUI

struct CategoryPickerField: View {
    let categories: [TaskCategory]
    @Binding var selectedCategoryID: UUID?
    let errorMessage: String?
    var allowsUnassigned = false
    var allowsCreation = false
    var colorForCategory: (UUID) -> ZoneColor? = { _ in nil }
    let onRetry: () -> Void
    var onCreateRequested: () -> Void = {}

    @State private var isPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Schedule.category)
                .font(AppFonts.subheadlineHeavy)
                .foregroundStyle(AppColors.textPrimary)

            Button {
                isPresented = true
            } label: {
                HStack(spacing: 10) {
                    Circle()
                        .fill(selectedColor)
                        .frame(width: 12, height: 12)
                    Text(selectedName)
                        .font(AppFonts.bodyBold)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.divider, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .popover(isPresented: $isPresented, arrowEdge: .bottom) {
                pickerContent
                    .presentationCompactAdaptation(.popover)
            }
        }
    }

    private var pickerContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    if allowsUnassigned {
                        option(title: L10n.Schedule.standalone, id: nil, color: nil)
                        Divider()
                    }

                    ForEach(categories) { category in
                        option(
                            title: category.name,
                            id: category.id,
                            color: colorForCategory(category.id)
                        )
                    }
                }
            }
            .frame(height: optionListHeight)

            if allowsCreation {
                Divider()
                Button {
                    isPresented = false
                    onCreateRequested()
                } label: {
                    Label(L10n.Categories.create, systemImage: "plus.circle.fill")
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.accentBlue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 9)
                }
                .buttonStyle(.plain)
            }

            if let errorMessage {
                Divider()
                Text(errorMessage)
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.warning)
                    .fixedSize(horizontal: false, vertical: true)
                Button(L10n.Templates.retry, action: onRetry)
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundStyle(AppColors.accentBlue)
            }
        }
        .padding(10)
        .frame(minWidth: 240)
        .background(AppColors.surface)
    }

    private var optionListHeight: CGFloat {
        let optionCount = categories.count + (allowsUnassigned ? 1 : 0)
        return min(max(CGFloat(optionCount) * 44, 44), 320)
    }

    private func option(
        title: String,
        id: UUID?,
        color: ZoneColor?
    ) -> some View {
        Button {
            selectedCategoryID = id
            isPresented = false
        } label: {
            HStack(spacing: 10) {
                Circle()
                    .fill(color.map { AppColors.runtime(hex: $0.hex) } ?? AppColors.runtimeFallback)
                    .frame(width: 10, height: 10)
                Text(title)
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer(minLength: 12)
                if selectedCategoryID == id {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.accentBlue)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var selectedName: String {
        guard let selectedCategoryID else { return L10n.Schedule.chooseCategory }
        return categories.first { $0.id == selectedCategoryID }?.name
            ?? L10n.Schedule.chooseCategory
    }

    private var selectedColor: Color {
        guard let selectedCategoryID,
              let color = colorForCategory(selectedCategoryID) else {
            return AppColors.runtimeFallback
        }
        return AppColors.runtime(hex: color.hex)
    }
}

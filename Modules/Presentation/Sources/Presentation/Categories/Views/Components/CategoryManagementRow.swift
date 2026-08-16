import Common
import Domain
import SwiftUI

struct CategoryManagementRow: View {
    let category: TaskCategory
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 16),
            contentInsets: EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        ) {
            HStack(spacing: 12) {
                Circle()
                    .fill(AppColors.accentBlue)
                    .frame(width: 8, height: 8)

                Text(category.name)
                    .font(AppFonts.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.accentBlue)
                        .padding(8)
                        .background(
                            AppColors.infoSurface,
                            in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.Categories.edit)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.destructive)
                        .padding(8)
                        .background(
                            AppColors.destructiveSurface,
                            in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.Categories.delete)
            }
        }
    }
}

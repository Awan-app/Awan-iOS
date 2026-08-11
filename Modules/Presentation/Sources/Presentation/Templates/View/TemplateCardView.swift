import Common
import Domain
import SwiftUI

struct TemplateCardView: View {
    let template: Template
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                Text(template.name)
                    .font(AppFonts.subheadlineHeavy)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Text(L10n.Templates.activeDaysCount(template.daysOfWeek.count))
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(width: 145, height: 70, alignment: .leading)
        }
        .buttonStyle(
            AppDepthButtonStyle(
                shape: .roundedRectangle(cornerRadius: 16),
                surfaceColor: AppColors.surface,
                borderColor: isSelected
                    ? AppColors.accentBlue.opacity(0.45)
                    : AppColors.outline.opacity(0.10),
                depthColor: isSelected
                    ? AppColors.accentBlueDepth
                    : AppColors.outline.opacity(0.16),
                borderWidth: isSelected ? 2 : 1.5,
                depthOffset: 4
            )
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

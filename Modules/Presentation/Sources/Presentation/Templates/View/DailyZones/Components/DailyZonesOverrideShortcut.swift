import Common
import Domain
import SwiftUI

struct DailyZonesOverrideShortcut: View {
    let templateOverride: TemplateOverride
    let isSelected: Bool
    let timeZone: TimeZone
    let onSelect: (Date) -> Void

    var body: some View {
        Button { onSelect(displayDate) } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Text(displayName)
                        .font(AppFonts.captionHeavy)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(AppFonts.caption2IconBlack)
                            .foregroundStyle(AppColors.accentPurple)
                    }
                }
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text(formattedDate)
                }
                .font(AppFonts.caption2Bold)
                .foregroundStyle(isSelected ? AppColors.accentPurple : AppColors.textSecondary)
            }
            .frame(width: 124, alignment: .leading)
            .padding(.horizontal, 11)
            .padding(.vertical, 9)
        }
        .buttonStyle(
            AppDepthButtonStyle(
                shape: .roundedRectangle(cornerRadius: 14),
                surfaceColor: AppColors.surface,
                borderColor: isSelected
                    ? AppColors.accentPurple.opacity(0.80)
                    : AppColors.outline.opacity(0.10),
                depthColor: isSelected
                    ? AppColors.accentPurple.opacity(0.38)
                    : AppColors.outline.opacity(0.16)
            )
        )
        .accessibilityLabel(
            L10n.Templates.overrideShortcutAccessibility(displayName, date: formattedDate)
        )
    }

    private var displayDate: Date {
        templateOverride.dateOfDay.date(in: timeZone)
    }

    private var displayName: String {
        if let name = templateOverride.name, !name.isEmpty {
            return name
        }
        return formattedDate
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.setLocalizedDateFormatFromTemplate("MMMdy")
        return formatter.string(from: displayDate)
    }
}

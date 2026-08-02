import SwiftUI
import Common
import Domain

struct TemplateCardView: View {
    let template: Template
    let isSelected: Bool
    let onTap: () -> Void

    private static let allDays = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"]

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text(template.name)
                        .font(AppFonts.subheadlineHeavy)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)

                    if isSelected {
                        Text(L10n.Templates.selectedBadge)
                            .font(AppFonts.microHeavy)
                            .foregroundStyle(AppColors.onAccent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                AppColors.accentBlue,
                                in: Capsule()
                            )
                    }
                }

                Text(L10n.Templates.activeDaysCount(template.daysOfWeek.count))
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.textSecondary)

                dayIndicators
            }
            .padding(12)
            .frame(width: 210, alignment: .leading)
        }
        .buttonStyle(
            AppDepthButtonStyle(
                shape: .roundedRectangle(cornerRadius: 16),
                surfaceColor: AppColors.surface,
                borderColor: isSelected ? AppColors.accentBlue.opacity(0.45) : AppColors.outline.opacity(0.10),
                depthColor: isSelected ? AppColors.accentBlueDepth : AppColors.outline.opacity(0.16),
                borderWidth: isSelected ? 2 : 1.5,
                depthOffset: 4
            )
        )
    }

    private var dayIndicators: some View {
        HStack(spacing: 6) {
            ForEach(Self.allDays, id: \.self) { day in
                let isActive = template.daysOfWeek.contains(where: { $0.uppercased() == day })
                VStack(spacing: 3) {
                    Text(dayLetter(day))
                        .font(AppFonts.microHeavy)
                        .foregroundStyle(isActive ? AppColors.textPrimary : AppColors.textSecondary.opacity(0.5))

                    Circle()
                        .fill(isActive ? AppColors.accentBlue : AppColors.divider)
                        .frame(width: 10, height: 10)
                }
            }
        }
    }

    private func dayLetter(_ day: String) -> String {
        switch day {
        case "MONDAY": return String(localized: "M", comment: "Monday short letter")
        case "TUESDAY": return String(localized: "T", comment: "Tuesday short letter")
        case "WEDNESDAY": return String(localized: "W", comment: "Wednesday short letter")
        case "THURSDAY": return String(localized: "T", comment: "Thursday short letter")
        case "FRIDAY": return String(localized: "F", comment: "Friday short letter")
        case "SATURDAY": return String(localized: "S", comment: "Saturday short letter")
        case "SUNDAY": return String(localized: "S", comment: "Sunday short letter")
        default: return "?"
        }
    }
}

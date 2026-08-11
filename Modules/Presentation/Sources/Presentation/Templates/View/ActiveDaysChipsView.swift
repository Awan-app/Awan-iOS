import Common
import Domain
import SwiftUI

struct ActiveDaysChipsView: View {
    let activeDays: Set<TemplateWeekday>
    let today: TemplateWeekday?
    var availability: [TemplateWeekdayAvailability] = []
    var onToggle: ((TemplateWeekday) -> Void)?

    var body: some View {
        HStack(spacing: 5) {
            ForEach(TemplateWeekday.allCases, id: \.self) { weekday in
                let active = activeDays.contains(weekday)
                let available = availability.first { $0.weekday == weekday }?.isAvailable ?? true
                Button {
                    onToggle?(weekday)
                } label: {
                    Text(weekday.localizedShortName)
                        .font(AppFonts.caption2Bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .foregroundStyle(active ? AppColors.onAccent : AppColors.textSecondary)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            active
                                ? AnyShapeStyle(AppColors.accentBlue.gradient)
                                : AnyShapeStyle(AppColors.surface),
                            in: RoundedRectangle(cornerRadius: 9, style: .continuous)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .stroke(
                                    weekday == today
                                        ? AppColors.accentBlue
                                        : AppColors.divider,
                                    lineWidth: weekday == today ? 2 : 1.5
                                )
                        }
                        .opacity(available || active ? 1 : 0.38)
                }
                .buttonStyle(.plain)
                .disabled(onToggle == nil || (!available && !active))
                .accessibilityLabel(weekday.localizedFullName)
                .accessibilityValue(
                    active
                        ? L10n.Templates.accessibilitySelected
                        : (available
                            ? L10n.Templates.accessibilityAvailable
                            : L10n.Templates.accessibilityUsed)
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}

extension TemplateWeekday {
    var localizedShortName: String {
        weekdaySymbol(full: false)
    }

    var localizedFullName: String {
        weekdaySymbol(full: true)
    }

    private func weekdaySymbol(full: Bool) -> String {
        let calendar = Calendar.current
        let values = full ? calendar.weekdaySymbols : calendar.shortWeekdaySymbols
        return values[calendarWeekday - 1]
    }
}

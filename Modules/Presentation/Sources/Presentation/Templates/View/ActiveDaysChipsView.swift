import SwiftUI
import Common

struct ActiveDaysChipsView: View {
    let activeDays: [String]

    private static let allDays: [(key: String, short: String)] = [
        ("MONDAY", "Mon"),
        ("TUESDAY", "Tue"),
        ("WEDNESDAY", "Wed"),
        ("THURSDAY", "Thu"),
        ("FRIDAY", "Fri"),
        ("SATURDAY", "Sat"),
        ("SUNDAY", "Sun")
    ]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Self.allDays, id: \.key) { day in
                let isActive = activeDays.contains(where: { $0.uppercased() == day.key })
                dayChip(label: localizedShortDay(day.key), isActive: isActive)
            }
        }
    }

    private func dayChip(label: String, isActive: Bool) -> some View {
        Text(label)
            .font(AppFonts.caption2Bold)
            .fixedSize(horizontal: true, vertical: false)
            .foregroundStyle(isActive ? AppColors.onAccent : AppColors.textSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(
                isActive
                    ? AnyShapeStyle(AppColors.accentBlue.gradient)
                    : AnyShapeStyle(Color.clear),
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .stroke(
                        isActive ? Color.clear : AppColors.divider,
                        lineWidth: 1.5
                    )
            }
    }

    private func localizedShortDay(_ day: String) -> String {
        // Use Calendar to get locale-aware short day names
        let calendar = Calendar.current
        let symbols = calendar.shortWeekdaySymbols // Sun, Mon, Tue, ...
        switch day {
        case "MONDAY": return symbols[1]
        case "TUESDAY": return symbols[2]
        case "WEDNESDAY": return symbols[3]
        case "THURSDAY": return symbols[4]
        case "FRIDAY": return symbols[5]
        case "SATURDAY": return symbols[6]
        case "SUNDAY": return symbols[0]
        default: return "?"
        }
    }
}

import SwiftUI
import Common

struct WeeklyCalendarHeader: View {
    let availableDays: [String]
    let selectedDay: String?
    let onSelectDay: (String) -> Void
    
    // Ordered days of week to ensure correct display order
    private let orderedDays = [
        "SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"
    ]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(orderedDays, id: \.self) { (day: String) in
                let isAvailable = availableDays.contains(day)
                let isSelected = selectedDay == day
                
                Button(action: {
                    if isAvailable {
                        onSelectDay(day)
                    }
                }) {
                    Text(dayPrefix(for: day))
                        .font(AppFonts.caption2Bold)
                        .frame(width: 40, height: 40)
                        .background(
                            isSelected ? AppColors.accentBlue : Color.clear,
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                        .foregroundStyle(
                            isSelected ? AppColors.onAccent : (isAvailable ? AppColors.textPrimary : AppColors.textSecondary.opacity(0.5))
                        )
                }
                .disabled(!isAvailable)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            AppColors.surface,
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .shadow(color: AppColors.shadow, radius: 10, x: 0, y: 4)
    }
    
    private func dayPrefix(for day: String) -> String {
        switch day.uppercased() {
        case "SUNDAY": return "S"
        case "MONDAY": return "M"
        case "TUESDAY": return "T"
        case "WEDNESDAY": return "W"
        case "THURSDAY": return "T"
        case "FRIDAY": return "F"
        case "SATURDAY": return "S"
        default: return String(day.prefix(1))
        }
    }
}

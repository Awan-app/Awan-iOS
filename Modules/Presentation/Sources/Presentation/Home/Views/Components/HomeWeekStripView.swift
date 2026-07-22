import Common
import SwiftUI

struct HomeWeekStripView: View {
    let selectedDay: Date
    let onSelect: (Date) -> Void
    @Namespace private var selection

    var body: some View {
        HStack(spacing: 6) {
            ForEach(days, id: \.self) { day in
                let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDay)
                Button { onSelect(day) } label: {
                    VStack(spacing: 6) {
                        Text(day.formatted(.dateTime.weekday(.abbreviated)))
                            .font(AppFonts.captionHeavy)
                        Text(day.formatted(.dateTime.day()))
                            .font(AppFonts.title3Black)
                    }
                    .foregroundStyle(isSelected ? AppColors.onAccent : AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .fill(AppColors.accentBlue.gradient)
                                .matchedGeometryEffect(id: "home-selected-day", in: selection)
                                .shadow(color: AppColors.accentBlueDepth, radius: 0, y: 4)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(day.formatted(date: .complete, time: .omitted))
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: selectedDay)
    }

    private var days: [Date] {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        let start = calendar.dateInterval(of: .weekOfYear, for: selectedDay)?.start
            ?? calendar.startOfDay(for: selectedDay)
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
    }
}

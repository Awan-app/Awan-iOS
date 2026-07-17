import SwiftUI

struct WeekStripView: View {
    let days: [Date]
    let selectedDay: Date
    let onSelect: (Date) -> Void
    @Namespace private var selection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("THIS WEEK")
                .font(.system(.caption, design: .rounded, weight: .black))
                .foregroundStyle(.secondary)
                .tracking(0.8)

            HStack(spacing: 7) {
                ForEach(days, id: \.self) { day in
                    let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDay)
                    Button { onSelect(day) } label: {
                        VStack(spacing: 7) {
                            Text(day.formatted(.dateTime.weekday(.narrow)))
                                .font(.system(.caption, design: .rounded, weight: .black))
                            Text(day.formatted(.dateTime.day()))
                                .font(.system(.headline, design: .rounded, weight: .black))
                        }
                        .foregroundStyle(isSelected ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(awanHex: "#58CC02").gradient)
                                    .matchedGeometryEffect(id: "selected-day", in: selection)
                                    .shadow(color: Color(awanHex: "#46A302"), radius: 0, y: 4)
                            } else {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.background)
                                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(day.formatted(date: .complete, time: .omitted))
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: selectedDay)
    }
}

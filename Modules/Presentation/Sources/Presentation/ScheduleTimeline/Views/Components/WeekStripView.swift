import Common
import SwiftUI

struct WeekStripView: View {
    let days: [Date]
    let selectedDay: Date
    let onSelect: (Date) -> Void
    @Namespace private var selection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("THIS WEEK")
                .font(AppFonts.captionBlack)
                .foregroundStyle(AppColors.textSecondary)
                .tracking(0.8)

            HStack(spacing: 7) {
                ForEach(days, id: \.self) { (day: Date) in
                    let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDay)
                    Button { onSelect(day) } label: {
                        VStack(spacing: 7) {
                            Text(day.formatted(.dateTime.weekday(.narrow)))
                                .font(AppFonts.captionBlack)
                            Text(day.formatted(.dateTime.day()))
                                .font(AppFonts.headlineBlack)
                        }
                        .foregroundStyle(
                            isSelected ? AppColors.onAccent : AppColors.textPrimary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppColors.accentGreen.gradient)
                                    .matchedGeometryEffect(id: "selected-day", in: selection)
                                    .shadow(color: AppColors.accentGreenDepth, radius: 0, y: 4)
                            } else {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppColors.surface)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(
                                                AppColors.outline.opacity(0.06),
                                                lineWidth: 1
                                            )
                                    }
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

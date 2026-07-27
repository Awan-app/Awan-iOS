import Common
import SwiftUI

struct HomeWeekStripView: View {
    let selectedDay: Date
    let onSelect: (Date) -> Void

    @State private var referenceDay: Date
    @Namespace private var selection
    @Environment(LanguageManager.self) private var languageManager

    init(
        selectedDay: Date,
        onSelect: @escaping (Date) -> Void
    ) {
        self.selectedDay = selectedDay
        self.onSelect = onSelect
        _referenceDay = State(initialValue: selectedDay)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 6) {
                    ForEach(days, id: \.self) { day in
                        dayButton(for: day)
                            .containerRelativeFrame(.horizontal, count: 7, spacing: 6)
                            .id(day)
                    }
                }
                .padding(.bottom, 4)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .task {
                await scrollToSelectedWeek(using: proxy, animated: false)
            }
            .onChange(of: selectedDay) {
                Task {
                    await scrollToSelectedWeek(using: proxy, animated: true)
                }
            }
        }
    }

    private func dayButton(for day: Date) -> some View {
        let isSelected = languageManager.calendar.isDate(day, inSameDayAs: selectedDay)
        let isToday = languageManager.calendar.isDateInToday(day)

        return Button { onSelect(day) } label: {
            VStack(spacing: 6) {
                Text(day.formatted(.dateTime.weekday(.abbreviated).locale(languageManager.locale)))
                    .font(AppFonts.captionHeavy)
                Text(day.formatted(.dateTime.day().locale(languageManager.locale)))
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
            .overlay {
                if isToday, !isSelected {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(AppColors.accentBlue.opacity(0.7), lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            day.formatted(
                Date.FormatStyle(
                    date: .complete,
                    time: .omitted,
                    locale: languageManager.locale
                )
            )
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var days: [Date] {
        let calendar = languageManager.calendar
        let reference = calendar.startOfDay(for: referenceDay)

        return (-366...366).compactMap {
            calendar.date(byAdding: .day, value: $0, to: reference)
        }
    }

    @MainActor
    private func scrollToSelectedWeek(
        using proxy: ScrollViewProxy,
        animated: Bool
    ) async {
        await Task.yield()
        let calendar = languageManager.calendar
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDay)?.start
            ?? calendar.startOfDay(for: selectedDay)

        if animated {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                proxy.scrollTo(weekStart, anchor: .leading)
            }
        } else {
            proxy.scrollTo(weekStart, anchor: .leading)
        }
    }
}


#Preview {
    HomeWeekStripView(selectedDay: Date(), onSelect: { _ in })
        .padding()
        .environment(LanguageManager())
}


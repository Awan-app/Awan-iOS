import Common
import SwiftUI

struct DailyZonesWeekNavigator: View {
    let viewModel: DailyZonesViewModel

    var body: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 18),
            contentInsets: EdgeInsets(top: 10, leading: 8, bottom: 14, trailing: 8)
        ) {
            VStack(spacing: 8) {
                navigationHeader
                daysRow
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    if value.translation.width < -40 {
                        viewModel.send(.nextWeek)
                    } else if value.translation.width > 40 {
                        viewModel.send(.previousWeek)
                    }
                }
        )
    }

    private var navigationHeader: some View {
        HStack {
            Button { viewModel.send(.previousWeek) } label: {
                Image(systemName: "chevron.backward")
                    .font(AppFonts.bodyBold)
            }
            Spacer()
            AppCalendarPickerButton(
                selection: Binding(
                    get: { viewModel.selectedDateValue },
                    set: { viewModel.send(.selectDate($0)) }
                ),
                title: L10n.Templates.overrideDate,
                in: Date.distantPast...Date.distantFuture
            ) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text(viewModel.selectedDateValue.formatted(.dateTime.month(.wide).year()))
                        .contentTransition(.numericText())
                    Image(systemName: "chevron.down")
                        .font(AppFonts.caption2Bold)
                }
                .font(AppFonts.subheadlineHeavy)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .environment(\.timeZone, viewModel.scheduleTimeZone)
            Spacer()
            Button { viewModel.send(.nextWeek) } label: {
                Image(systemName: "chevron.forward")
                    .font(AppFonts.bodyBold)
            }
        }
        .foregroundStyle(AppColors.accentBlue)
    }

    private var daysRow: some View {
        ZStack {
            HStack(spacing: 4) {
                ForEach(viewModel.currentWeekDates, id: \.self) { date in
                    dayButton(date)
                }
            }
            .id(viewModel.currentWeekDates.first)
            .transition(weekTransition)
        }
        .clipped()
        .animation(.snappy(duration: 0.34), value: viewModel.currentWeekDates.first)
    }

    private func dayButton(_ date: Date) -> some View {
        let selected = viewModel.isDateSelected(date)
        return Button { viewModel.send(.selectDate(date)) } label: {
            VStack(spacing: 4) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(AppFonts.caption2Bold)
                Text(date.formatted(.dateTime.day()))
                    .font(AppFonts.title3Bold)
                Circle()
                    .fill(viewModel.hasOverride(on: date) ? AppColors.accentPurple : AppColors.divider)
                    .frame(width: 5, height: 5)
            }
            .foregroundStyle(selected ? AppColors.onAccent : AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                selected ? AppColors.accentBlue : AppColors.surface,
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay {
                if viewModel.isDateToday(date) {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.accentBlue, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var weekTransition: AnyTransition {
        let movingForward = viewModel.state.weekNavigationDirection == .forward
        return .asymmetric(
            insertion: .move(edge: movingForward ? .trailing : .leading).combined(with: .opacity),
            removal: .move(edge: movingForward ? .leading : .trailing).combined(with: .opacity)
        )
    }
}

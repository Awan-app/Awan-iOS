import SwiftUI
import Common

public struct DailyZonesView: View {
    @Bindable var viewModel: DailyZonesViewModel
    
    @State private var draggedZone: SuggestedZone?
    @State private var dragOffset: CGSize = .zero
    @State private var cumulativeOffset: CGFloat = 0

    public init(viewModel: DailyZonesViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 16)

            // Weekly Strip
            WeeklyCalendarHeader(
                availableDays: viewModel.availableDays,
                selectedDay: viewModel.selectedDay,
                onSelectDay: { viewModel.selectDay($0) }
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 24)

            if viewModel.state == .loading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    zonesListWithTimeline
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }
            }
            
            Spacer(minLength: 0)

            bottomButton
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .task {
            await viewModel.load()
        }
        .sheet(isPresented: $viewModel.isAddZoneSheetPresented) {
            AddZoneSheet(viewModel: viewModel)
        }
        .sheet(item: $viewModel.editingZone) { zone in
            EditZoneTimeSheet(viewModel: viewModel, zone: zone)
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
    }

    private var headerSection: some View {
        HStack {
            Button(action: {
                // Handle back navigation if needed
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppColors.accentBlue)
                    .frame(width: 44, height: 44)
                    .background(Color.white, in: Circle())
                    .shadow(color: AppColors.shadow, radius: 4, y: 2)
            }
            Spacer()
            VStack(alignment: .center, spacing: 4) {
                Text("Daily zones")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.brandDarkBlue)
                
                if let day = viewModel.selectedDay {
                    Text("Shape \(day.capitalized) your way.")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            Spacer()
            Image(systemName: "cloud.fill") // Placeholder for cloud character
                .font(.system(size: 30))
                .foregroundStyle(AppColors.accentBlue.opacity(0.3))
        }
    }

    private var zonesListWithTimeline: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.suggestedZones) { zone in
                HStack(alignment: .top, spacing: 16) {
                    // Timeline indicator
                    timelineIndicator(for: zone)
                    
                    // Zone Card
                    ZoneCard(zone: zone) {
                        withAnimation(.snappy(duration: 0.25)) {
                            viewModel.removeZone(zone)
                        }
                    }
                    .onTapGesture {
                        viewModel.editingZone = zone
                    }
                    .offset(y: draggedZone == zone ? dragOffset.height : 0)
                    .zIndex(draggedZone == zone ? 1 : 0)
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged { value in
                                if draggedZone == nil {
                                    draggedZone = zone
                                    cumulativeOffset = 0
                                }
                                
                                dragOffset = CGSize(width: 0, height: value.translation.height - cumulativeOffset)
                                
                                if let currentIndex = viewModel.suggestedZones.firstIndex(of: zone) {
                                    let itemHeight: CGFloat = 74
                                    
                                    if dragOffset.height > itemHeight && currentIndex < viewModel.suggestedZones.count - 1 {
                                        cumulativeOffset += itemHeight
                                        dragOffset.height -= itemHeight
                                        withAnimation(.snappy(duration: 0.25)) {
                                            viewModel.swapZones(at: currentIndex, with: currentIndex + 1)
                                        }
                                    } else if dragOffset.height < -itemHeight && currentIndex > 0 {
                                        cumulativeOffset -= itemHeight
                                        dragOffset.height += itemHeight
                                        withAnimation(.snappy(duration: 0.25)) {
                                            viewModel.swapZones(at: currentIndex, with: currentIndex - 1)
                                        }
                                    }
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.snappy(duration: 0.25)) {
                                    draggedZone = nil
                                    dragOffset = .zero
                                    cumulativeOffset = 0
                                }
                            }
                    )
                }
            }

            // Add zone button with timeline
            HStack(alignment: .center, spacing: 16) {
                // Empty timeline spacer
                VStack {
                    Text("").font(AppFonts.caption2Bold).frame(width: 45, alignment: .trailing)
                }
                
                AddZoneButton(onTap: {
                    viewModel.isAddZoneSheetPresented = true
                })
            }
        }
    }

    private func timelineIndicator(for zone: SuggestedZone) -> some View {
        let isOutside = isZoneOutsideHours(zone)
        let color = isOutside ? AppColors.warning : AppColors.accentBlue

        return VStack(spacing: 0) {
            Text(formattedTimelineTime(zone.startTime))
                .font(AppFonts.caption2Bold)
                .foregroundStyle(color)
                .frame(width: 45, alignment: .trailing)
            
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Rectangle()
                    .fill(color.opacity(0.3))
                    .frame(width: 2)
            }
            .padding(.leading, 37) // Align with the end of the text
            .padding(.top, 4)
        }
    }

    private func isZoneOutsideHours(_ zone: SuggestedZone) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let start = formatter.date(from: zone.startTime),
              let end = formatter.date(from: zone.endTime) else {
            return false
        }
        
        return viewModel.isTimeIntervalOutsideActiveHours(start: start, end: end)
    }

    private func formattedTimelineTime(_ timeString: String) -> String {
        // Just extract the hour and AM/PM part for the timeline UI if needed, or return as is
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = formatter.date(from: timeString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "h a"
            return outputFormatter.string(from: date)
        }
        return timeString
    }

    private var bottomButton: some View {
        AppButton(
            title: "Save \(viewModel.selectedDay?.capitalized ?? "Day")",
            icon: "checkmark.circle.fill",
            color: AppColors.accentBlue,
            foregroundColor: AppColors.onAccent,
            onTap: {
                Task {
                    await viewModel.saveCurrentTemplate()
                }
            }
        )
    }
}

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
            if viewModel.state == .loading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                GeometryReader { proxy in
                    ScrollView {
                        zonesListWithTimeline
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                            .frame(minHeight: proxy.size.height)
                    }
                }
            }
            
            Spacer(minLength: 0)

            bottomButton
                .padding(.horizontal, 24)
                .padding(.bottom, 48) // Increased bottom padding
        }
        .navigationTitle(L10n.Templates.dailyZonesTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                GifImageView("awan-mascot-clock")
                    .frame(width: 50, height: 50)
            }
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



    private var zonesListWithTimeline: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.suggestedZones) { zone in
                HStack(alignment: .top, spacing: 10) {
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
            HStack(alignment: .center, spacing: 10) {
                // Empty timeline spacer
                VStack {
                    Text("").font(AppFonts.caption2Bold).frame(width: 45, alignment: .trailing)
                }
                
                AddZoneButton(onTap: {
                    viewModel.isAddZoneSheetPresented = true
                })
            }
        }
        .background(alignment: .topLeading) {
            // Continuous Timeline Line
            Rectangle()
                .fill(AppColors.accentBlue.opacity(0.3))
                .frame(width: 2)
                .padding(.leading, 40)
                .padding(.top, 22)
                .padding(.bottom, 30)
        }
    }

    private func timelineIndicator(for zone: SuggestedZone) -> some View {
        let isOutside = viewModel.isZoneOutsideActiveHours(zone)
        let color = isOutside ? AppColors.warning : AppColors.accentBlue

        return VStack(spacing: 0) {
            Text(zone.startTime)
                .font(AppFonts.caption2Bold)
                .foregroundStyle(color)
                .frame(width: 45, alignment: .trailing)
            
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .padding(.leading, 37) // Align with the end of the text
                .padding(.top, 4)
        }
    }

    private var bottomButton: some View {
        AppButton(
            title: L10n.Schedule.saveChanges,
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

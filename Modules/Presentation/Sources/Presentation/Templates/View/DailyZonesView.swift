import SwiftUI
import Common
import Domain

public struct DailyZonesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppearanceManager.self) private var appearanceManager
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
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        templatesSection
                        templateDetailCard
                        scheduleSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            
            bottomButton
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 16)
                .background(AppColors.screenBackground.ignoresSafeArea(edges: .bottom))
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle(L10n.Templates.dailyZonesTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.body.weight(.semibold))
                }
                .foregroundColor(AppColors.accentBlue)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                GifImageView("awan-mascot-clock")
                    .frame(width: 85, height: 85)
            }
        }
        .task {
            await viewModel.load()
        }
        .sheet(isPresented: $viewModel.isAddZoneSheetPresented) {
            AddZoneSheet(viewModel: viewModel)
                .preferredColorScheme(appearanceManager.currentAppearance.colorScheme)
        }
        .sheet(item: $viewModel.editingZone) { zone in
            EditZoneTimeSheet(viewModel: viewModel, zone: zone)
                .preferredColorScheme(appearanceManager.currentAppearance.colorScheme)
        }
        .alert(L10n.Schedule.errorTitle, isPresented: errorBinding) {
            Button(L10n.Common.gotIt) {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.errorMessage ?? L10n.Common.pleaseTryAgain)
        }
        .background(AppColors.screenBackground.ignoresSafeArea())
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissError()
                }
            }
        )
    }

    // MARK: - Templates Section

    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header row: "Templates" title + "+ New" button
            HStack {
                Text(L10n.Templates.sectionTitle)
                    .font(AppFonts.title2Black)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                AppButton(
                    title: L10n.Templates.newButton,
                    icon: "plus",
                    color: AppColors.accentBlue,
                    foregroundColor: AppColors.onAccent,
                    size: .compact,
                    expandsHorizontally: false,
                    onTap: {
                        // Placeholder — new template creation flow
                    }
                )
            }

            // Horizontal template cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.templates) { template in
                        TemplateCardView(
                            template: template,
                            isSelected: template.id == viewModel.selectedTemplateId,
                            onTap: {
                                withAnimation(.snappy(duration: 0.25)) {
                                    viewModel.selectTemplate(template)
                                }
                            }
                        )
                    }

                    // "+" add template button at end
                    Button {
                        // Placeholder — new template creation flow
                    } label: {
                        VStack {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(AppColors.accentBlue)
                        }
                        .frame(width: 54, height: 74)
                    }
                    .buttonStyle(
                        AppDepthButtonStyle(
                            shape: .roundedRectangle(cornerRadius: 16),
                            surfaceColor: AppColors.surface,
                            borderColor: AppColors.outline.opacity(0.10),
                            depthColor: AppColors.outline.opacity(0.16),
                            depthOffset: 4
                        )
                    )
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - Template Detail Card

    private var templateDetailCard: some View {
        AppDepthSurface(
            shape: .roundedRectangle(cornerRadius: 20),
            contentInsets: EdgeInsets(top: 16, leading: 18, bottom: 18, trailing: 18)
        ) {
            VStack(alignment: .leading, spacing: 14) {
                // Template name with edit pencil
                if let selected = viewModel.templates.first(where: { $0.id == viewModel.selectedTemplateId }) {
                    HStack(spacing: 8) {
                        Text(selected.name)
                            .font(AppFonts.headlineBlack)
                            .foregroundStyle(AppColors.textPrimary)

                        Button {
                            // Placeholder — rename template action
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }

                    // Active days header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Templates.activeDaysTitle)
                            .font(AppFonts.subheadlineHeavy)
                            .foregroundStyle(AppColors.textPrimary)

                        Text(L10n.Templates.activeDaysSubtitle)
                            .font(AppFonts.caption2Bold)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    // Day chips
                    ActiveDaysChipsView(activeDays: selected.daysOfWeek)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Schedule Section

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Schedule header with zone count
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(L10n.Templates.scheduleTitle)
                    .font(AppFonts.title3Black)
                    .foregroundStyle(AppColors.textPrimary)

                Text(L10n.Templates.zonesCount(viewModel.suggestedZones.count))
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.textSecondary)
            }

            zonesListWithTimeline
        }
    }

    // MARK: - Zones Timeline

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
                    Text("").font(AppFonts.caption2Bold).frame(width: 58, alignment: .trailing)
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
                .padding(.leading, 53)
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
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .foregroundStyle(color)
                .frame(width: 58, alignment: .trailing)
            
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .padding(.leading, 50)
                .padding(.top, 4)
        }
    }

    private var bottomButton: some View {
        AppButton(
            title: L10n.Templates.saveTemplate,
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

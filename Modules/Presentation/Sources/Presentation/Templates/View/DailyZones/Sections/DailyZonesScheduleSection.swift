import Common
import SwiftUI

struct DailyZonesScheduleSection: View {
    let viewModel: DailyZonesViewModel
    let editable: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(L10n.Templates.scheduleTitle)
                    .font(AppFonts.title3Black)
                    .foregroundStyle(AppColors.textPrimary)
                Text(L10n.Templates.zonesCount(viewModel.state.zones.count))
                    .font(AppFonts.caption2Bold)
                    .foregroundStyle(AppColors.textSecondary)
            }

            if viewModel.state.zones.isEmpty {
                DailyZonesEmptyCard(
                    icon: "clock",
                    title: L10n.Templates.noZonesYet,
                    message: L10n.Templates.addFirstZone,
                    actionTitle: editable ? L10n.Onboarding.addZone : nil,
                    action: editable ? { viewModel.send(.presentAddZone) } : nil
                )
            } else {
                zonesTimeline
            }

            if editable && !viewModel.state.zones.isEmpty {
                AddZoneButton { viewModel.send(.presentAddZone) }
            }
        }
    }

    private var zonesTimeline: some View {
        VStack(spacing: 14) {
            ForEach(viewModel.state.zones) { zone in
                HStack(alignment: .top, spacing: 10) {
                    DailyZonesTimelineIndicator(viewModel: viewModel, zone: zone)
                    DailyZoneScheduleCard(viewModel: viewModel, zone: zone, editable: editable)
                        .offset(
                            y: viewModel.state.zoneDrag?.zoneID == zone.id
                                ? CGFloat(viewModel.state.zoneDrag?.offset ?? 0)
                                : 0
                        )
                        .zIndex(viewModel.state.zoneDrag?.zoneID == zone.id ? 1 : 0)
                        .gesture(dragGesture(for: zone))
                        .accessibilityHint(editable ? L10n.Templates.dragZoneHint : "")
                }
            }
        }
        .animation(.snappy(duration: 0.25), value: viewModel.state.zones.map(\.id))
        .background(alignment: .topLeading) {
            Rectangle()
                .fill(AppColors.accentBlue.opacity(0.3))
                .frame(width: 2)
                .padding(.leading, 53)
                .padding(.top, 22)
                .padding(.bottom, 30)
        }
    }

    private func dragGesture(for zone: DailyZoneDraft) -> some Gesture {
        DragGesture(
            minimumDistance: editable ? 8 : .infinity,
            coordinateSpace: .global
        )
        .onChanged { value in
            guard editable else { return }
            viewModel.send(
                .dragZone(
                    id: zone.id,
                    translation: Double(value.translation.height),
                    rowStride: 80
                )
            )
        }
        .onEnded { _ in
            guard editable else { return }
            withAnimation(.snappy(duration: 0.25)) {
                viewModel.send(.endZoneDrag)
            }
        }
    }
}

private struct DailyZonesTimelineIndicator: View {
    let viewModel: DailyZonesViewModel
    let zone: DailyZoneDraft

    var body: some View {
        let color = viewModel.isZoneOutsideActiveHours(zone)
            ? AppColors.warning
            : AppColors.accentBlue
        VStack(spacing: 0) {
            Text(viewModel.formattedTime(zone.startTime))
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
}

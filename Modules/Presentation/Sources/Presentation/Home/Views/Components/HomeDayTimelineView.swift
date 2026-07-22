import Common
import SwiftUI

struct HomeDayTimelineView: View {
    static let hourHeight: CGFloat = 80

    let window: HomeTimelineWindow
    let zones: [HomeTimelineZoneItem]
    let items: [HomeTimelineItem]
    let onMove: (UUID, CGFloat) -> Void
    let onSetCompletion: (UUID, Bool) -> Void
    let onTap: (UUID) -> Void

    private var totalHeight: CGFloat {
        CGFloat(window.durationMinutes) / 60 * Self.hourHeight + (verticalInset * 2)
    }

    private var verticalInset: CGFloat {
        Self.hourHeight / 4
    }

    var body: some View {
        GeometryReader { geometry in
            let labelWidth: CGFloat = 52
            let plotWidth = max(0, geometry.size.width - labelWidth)

            ZStack(alignment: .topLeading) {
                HomeTimelineBackgroundView(
                    window: window,
                    zones: zones,
                    labelWidth: labelWidth,
                    plotWidth: plotWidth,
                    hourHeight: Self.hourHeight
                )

                ForEach(items) { item in
                    sessionCard(
                        item,
                        labelWidth: labelWidth,
                        plotWidth: plotWidth
                    )
                }

                if items.isEmpty {
//                    HomeTimelineEmptyStateView()
//                        .frame(width: max(0, plotWidth - 20))
//                        .offset(x: labelWidth + 10, y: Self.hourHeight * 1.25)
                }

                HomeTimelineCurrentTimeIndicator(
                    window: window,
                    width: geometry.size.width,
                    labelWidth: labelWidth,
                    hourHeight: Self.hourHeight
                )
            }
            .offset(y: verticalInset)
        }
        .frame(height: totalHeight)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColors.outline.opacity(0.08), lineWidth: 1.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: AppColors.shadow.opacity(0.08), radius: 16, y: 7)
    }

    private func sessionCard(
        _ item: HomeTimelineItem,
        labelWidth: CGFloat,
        plotWidth: CGFloat
    ) -> some View {
        let spacing: CGFloat = 6
        let lanes = CGFloat(max(1, item.laneCount))
        let cardWidth = max(0, (plotWidth - 16 - (lanes - 1) * spacing) / lanes)
        let x = labelWidth + 8 + CGFloat(item.lane) * (cardWidth + spacing)
        let scheduledHeight = CGFloat(item.durationMinutes) / 60 * Self.hourHeight

        return HomeTimelineSessionCard(
            item: item,
            onMove: { onMove(item.id, $0) },
            onSetCompletion: { onSetCompletion(item.id, $0) },
            onTap: { onTap(item.id) }
        )
        .frame(
            width: cardWidth,
            height: max(34, scheduledHeight - 8)
        )
        .offset(x: x)
        .animation(
            .spring(response: 0.34, dampingFraction: 0.86),
            value: laneAnimationKey(for: item)
        )
        .offset(y: yPosition(for: item.start) + 2)
    }

    private func yPosition(for date: Date) -> CGFloat {
        CGFloat(date.timeIntervalSince(window.start) / 3600) * Self.hourHeight
    }

    private func laneAnimationKey(for item: HomeTimelineItem) -> Int {
        (item.laneCount * 1_000) + item.lane
    }
}

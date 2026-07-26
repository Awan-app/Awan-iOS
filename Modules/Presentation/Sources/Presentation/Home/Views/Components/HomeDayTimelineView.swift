import Common
import SwiftUI

struct HomeDayTimelineView: View {
    static let hourHeight: CGFloat = 80
    private static let minimumZoomScale: CGFloat = 0.75
    private static let maximumZoomScale: CGFloat = 4

    let window: HomeTimelineWindow
    let wakeupTime: Date
    let bedtime: Date
    let zones: [HomeTimelineZoneItem]
    let items: [HomeTimelineItem]
    let onMove: (UUID, CGFloat) -> Void
    let onSetCompletion: (UUID, Bool) -> Void
    let onTap: (UUID) -> Void

    @State private var zoomScale: CGFloat = 1
    @GestureState private var gestureScale: CGFloat = 1

    private var displayedZoomScale: CGFloat {
        clampedZoomScale(zoomScale * gestureScale)
    }

    private var displayedHourHeight: CGFloat {
        Self.hourHeight * displayedZoomScale
    }

    private var totalHeight: CGFloat {
        CGFloat(window.durationMinutes) / 60 * displayedHourHeight + (verticalInset * 2)
    }

    private var verticalInset: CGFloat {
        displayedHourHeight / 4
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
                    hourHeight: displayedHourHeight
                )

                ForEach(items) { item in
                    sessionCard(
                        item,
                        labelWidth: labelWidth,
                        plotWidth: plotWidth
                    )
                }

                HomeTimelineDayMarkersView(
                    window: window,
                    wakeupTime: wakeupTime,
                    bedtime: bedtime,
                    width: geometry.size.width,
                    labelWidth: labelWidth,
                    hourHeight: displayedHourHeight
                )

                if items.isEmpty {
//                    HomeTimelineEmptyStateView()
//                        .frame(width: max(0, plotWidth - 20))
//                        .offset(x: labelWidth + 10, y: Self.hourHeight * 1.25)
                }

                HomeTimelineCurrentTimeIndicator(
                    window: window,
                    width: geometry.size.width,
                    labelWidth: labelWidth,
                    hourHeight: displayedHourHeight
                )

                if Date.now >= window.start, Date.now < window.end {
                    Color.clear
                        .frame(width: 1, height: 1)
                        .offset(y: yPosition(for: .now))
                        .id(HomeTimelineScrollAnchor.currentTime)
                }
            }
            .offset(y: verticalInset)
        }
        .frame(height: totalHeight)
        .simultaneousGesture(zoomGesture)
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
        let scheduledHeight = CGFloat(item.durationMinutes) / 60 * displayedHourHeight

        return HomeTimelineSessionCard(
            item: item,
            onMove: { onMove(item.id, $0 / displayedZoomScale) },
            onSetCompletion: { onSetCompletion(item.id, $0) },
            onTap: { onTap(item.id) }
        )
        .frame(
            width: cardWidth,
            height: max(16, scheduledHeight - 8)
        )
        .offset(x: x)
        .animation(
            .spring(response: 0.34, dampingFraction: 0.86),
            value: laneAnimationKey(for: item)
        )
        .offset(y: yPosition(for: item.start) + 2)
    }

    private func yPosition(for date: Date) -> CGFloat {
        CGFloat(date.timeIntervalSince(window.start) / 3600) * displayedHourHeight
    }

    private func laneAnimationKey(for item: HomeTimelineItem) -> Int {
        (item.laneCount * 1_000) + item.lane
    }

    private var zoomGesture: some Gesture {
        MagnifyGesture(minimumScaleDelta: 0.01)
            .updating($gestureScale) { value, state, _ in
                state = value.magnification
            }
            .onEnded { value in
                zoomScale = clampedZoomScale(zoomScale * value.magnification)
            }
    }

    private func clampedZoomScale(_ scale: CGFloat) -> CGFloat {
        min(max(scale, Self.minimumZoomScale), Self.maximumZoomScale)
    }
}

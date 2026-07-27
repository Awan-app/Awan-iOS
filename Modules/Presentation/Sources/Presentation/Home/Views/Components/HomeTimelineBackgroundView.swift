import Common
import SwiftUI

struct HomeTimelineBackgroundView: View {
    let window: HomeTimelineWindow
    let zones: [HomeTimelineZoneItem]
    let labelWidth: CGFloat
    let plotWidth: CGFloat
    let hourHeight: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            zoneBands
            zoneRail
            hourGrid
        }
    }

    private var zoneBands: some View {
        ForEach(zones) { zone in
            let height = yPosition(for: zone.end) - yPosition(for: zone.start)
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(zone.color.opacity(0.09))
                Text(zone.name.uppercased())
                    .font(AppFonts.microBlack)
                    .foregroundStyle(zone.color.opacity(0.8))
                    .padding(.top, 7)
                    .padding(.leading, 10)
            }
            .frame(width: plotWidth, height: height)
            .offset(x: labelWidth, y: yPosition(for: zone.start))
        }
    }

    private var zoneRail: some View {
        ForEach(zones) { zone in
            let height = yPosition(for: zone.end) - yPosition(for: zone.start)

            Rectangle()
                .fill(zone.color)
                .frame(width: 4, height: height)
                .shadow(color: zone.color.opacity(0.55), radius: 3)
                .offset(x: labelWidth - 2, y: yPosition(for: zone.start))
        }
    }

    private var hourGrid: some View {
        ForEach(Array(timeMarkers.enumerated()), id: \.offset) { index, marker in
            let date = marker.date
            let y = yPosition(for: date)
            Text(timeLabel(for: marker))
                .font(AppFonts.hourLabel)
                .foregroundStyle(
                    AppColors.textSecondary.opacity(marker.isMajorHour ? 1 : 0.72)
                )
                .frame(width: labelWidth - 10, alignment: .trailing)
                .offset(y: index == 0 ? 7 : y - 7)

            Rectangle()
                .fill(
                    AppColors.textPrimary.opacity(marker.isMajorHour ? 0.10 : 0.045)
                )
                .frame(width: plotWidth, height: marker.isMajorHour ? 1 : 0.5)
                .offset(x: labelWidth, y: y)
        }
    }

    private var timeMarkers: [HomeTimelineGridMarker] {
        let interval = markerIntervalMinutes
        var minuteOffsets = Array(stride(
            from: 0,
            through: window.durationMinutes,
            by: interval
        ))
        if minuteOffsets.last != window.durationMinutes {
            minuteOffsets.append(window.durationMinutes)
        }

        return minuteOffsets.map { minutes in
            HomeTimelineGridMarker(
                date: window.start.addingTimeInterval(Double(minutes) * 60),
                isMajorHour: minutes.isMultiple(of: 60)
            )
        }
    }

    private var markerIntervalMinutes: Int {
        switch hourHeight {
        case 240...:
            return 5
        case 140..<240:
            return 15
        case 100..<140:
            return 30
        default:
            return 60
        }
    }

    private func yPosition(for date: Date) -> CGFloat {
        CGFloat(date.timeIntervalSince(window.start) / 3600) * hourHeight
    }

    private func timeLabel(for marker: HomeTimelineGridMarker) -> String {
        if marker.isMajorHour {
            return marker.date.formatted(date: .omitted, time: .shortened)
                .replacingOccurrences(of: ":00", with: "")
        }

        return marker.date.formatted(
            .dateTime
                .hour(.defaultDigits(amPM: .omitted))
                .minute(.twoDigits)
        )
    }
}

private struct HomeTimelineGridMarker {
    let date: Date
    let isMajorHour: Bool
}

struct HomeTimelineCurrentTimeIndicator: View {
    let window: HomeTimelineWindow
    let width: CGFloat
    let labelWidth: CGFloat
    let hourHeight: CGFloat

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            if context.date >= window.start, context.date < window.end {
                HStack(spacing: 0) {
                    Text(context.date.formatted(date: .omitted, time: .shortened))
                        .font(AppFonts.caption2Bold)
                        .foregroundStyle(AppColors.brandDarkBlue)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 5)
                        .background(AppColors.surface, in: Capsule())
                        .overlay { Capsule().stroke(AppColors.divider, lineWidth: 1) }
                    Circle().fill(AppColors.accentBlue).frame(width: 8, height: 8)
                    Rectangle()
                        .fill(AppColors.accentBlue)
                        .frame(width: max(0, width - labelWidth), height: 2)
                }
                .offset(x: 2, y: yPosition(for: context.date) - 14)
            }
        }
    }

    private func yPosition(for date: Date) -> CGFloat {
        CGFloat(date.timeIntervalSince(window.start) / 3600) * hourHeight
    }
}

struct HomeTimelineDayMarkersView: View {
    let window: HomeTimelineWindow
    let wakeupTime: Date
    let bedtime: Date
    let width: CGFloat
    let labelWidth: CGFloat
    let hourHeight: CGFloat

    var body: some View {
        Group {
            marker(
                at: wakeupTime,
                title: L10n.Home.wakeUp,
                icon: "sunrise.fill",
                color: AppColors.warning
            )
            marker(
                at: bedtime,
                title: L10n.Home.bedtime,
                icon: "moon.fill",
                color: AppColors.accentPurple
            )
        }
        .allowsHitTesting(false)
    }

    private func marker(
        at date: Date,
        title: String,
        icon: String,
        color: Color
    ) -> some View {
        ZStack(alignment: .trailing) {
            Path { path in
                path.move(to: CGPoint(x: labelWidth, y: 12))
                path.addLine(to: CGPoint(x: width, y: 12))
            }
            .stroke(
                color.opacity(0.75),
                style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
            )

            Label(title, systemImage: icon)
                .font(AppFonts.caption2Bold)
                .foregroundStyle(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(AppColors.surface, in: Capsule())
                .overlay { Capsule().stroke(color.opacity(0.45), lineWidth: 1) }
                .padding(.trailing, 8)
        }
        .frame(width: width, height: 24)
        .offset(y: yPosition(for: date) - 12)
        .accessibilityLabel(
            "\(title), \(date.formatted(date: .omitted, time: .shortened))"
        )
    }

    private func yPosition(for date: Date) -> CGFloat {
        CGFloat(date.timeIntervalSince(window.start) / 3600) * hourHeight
    }
}

struct HomeTimelineEmptyStateView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(AppFonts.nudgeSymbol)
                .foregroundStyle(AppColors.accentBlue)
            Text(L10n.Schedule.emptyTitle)
                .font(AppFonts.headlineBlack)
                .foregroundStyle(AppColors.textPrimary)
            Text(L10n.Home.emptyTimelineSubtitle)
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
}


import Domain
#Preview {
    HomeTimelineBackgroundView(window: HomeTimelineWindow(start: Date(), end: Date().addingTimeInterval(3600)), zones: [], labelWidth: 50, plotWidth: 300, hourHeight: 80)
        .padding()
}


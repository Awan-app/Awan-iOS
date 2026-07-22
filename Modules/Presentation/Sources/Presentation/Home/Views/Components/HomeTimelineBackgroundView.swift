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
            hourGrid
        }
    }

    private var zoneBands: some View {
        ForEach(zones) { zone in
            let height = CGFloat(zone.end.timeIntervalSince(zone.start) / 3600) * hourHeight
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

    private var hourGrid: some View {
        ForEach(Array(hourMarkers.enumerated()), id: \.offset) { index, date in
            let y = yPosition(for: date)
            Text(hourLabel(for: date))
                .font(AppFonts.hourLabel)
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: labelWidth - 10, alignment: .trailing)
                .offset(y: index == 0 ? 7 : y - 7)

            Rectangle()
                .fill(AppColors.textPrimary.opacity(0.08))
                .frame(width: plotWidth, height: 1)
                .offset(x: labelWidth, y: y)
        }
    }

    private var hourMarkers: [Date] {
        let wholeHours = window.durationMinutes / 60
        var markers = (0...wholeHours).map {
            window.start.addingTimeInterval(Double($0) * 60 * 60)
        }
        if window.durationMinutes.isMultiple(of: 60) == false {
            markers.append(window.end)
        }
        return markers
    }

    private func yPosition(for date: Date) -> CGFloat {
        CGFloat(date.timeIntervalSince(window.start) / 3600) * hourHeight
    }

    private func hourLabel(for date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
            .replacingOccurrences(of: ":00", with: "")
    }
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

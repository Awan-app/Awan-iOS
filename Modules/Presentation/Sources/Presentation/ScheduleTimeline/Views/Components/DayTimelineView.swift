import Common
import SwiftUI

struct DayTimelineView: View {
    @Environment(LanguageManager.self) private var languageManager
    static let startHour = 7
    static let endHour = 24
    static let hourHeight: CGFloat = 76

    let zones: [TimelineZoneItem]
    let items: [TimelineSessionItem]
    let onMove: (UUID, CGFloat) -> Void
    let onTap: (UUID) -> Void

    private var totalHeight: CGFloat {
        CGFloat(Self.endHour - Self.startHour) * Self.hourHeight
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            GeometryReader { geometry in
                let labelWidth: CGFloat = 51
                let plotWidth = max(0, geometry.size.width - labelWidth)

                ZStack(alignment: .topLeading) {
                    zoneBands(labelWidth: labelWidth, plotWidth: plotWidth)
                    hourGrid(labelWidth: labelWidth)

                    ForEach(items) { item in
                        let spacing: CGFloat = 6
                        let lanes = CGFloat(max(1, item.laneCount))
                        let cardWidth = (plotWidth - 16 - (lanes - 1) * spacing) / lanes
                        let x = labelWidth + 8 + CGFloat(item.lane) * (cardWidth + spacing)
                        let y = yPosition(forMinutes: item.startMinutes)
                        TimelineSessionCard(item: item) { points in
                            onMove(item.id, points)
                        } onTap: {
                            onTap(item.taskID)
                        }
                        .frame(width: cardWidth, height: max(46, CGFloat(item.durationMinutes) / 60 * Self.hourHeight - 4))
                        .offset(x: x, y: y + 2)
                        .zIndex(item.blocking ? 3 : 2)
                    }

                    if items.isEmpty {
                        emptyState(plotWidth: plotWidth)
                            .offset(x: labelWidth + 10, y: Self.hourHeight * 2.1)
                    }
                }
            }
            .frame(height: totalHeight)
        }
        .frame(minHeight: 520)
        .background(
            AppColors.surface,
            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(AppColors.outline.opacity(0.05), lineWidth: 1.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: AppColors.shadow.opacity(0.06), radius: 16, y: 7)
    }

    @ViewBuilder
    private func zoneBands(labelWidth: CGFloat, plotWidth: CGFloat) -> some View {
        ForEach(zones) { zone in
            let start = zone.startMinutes
            let rawEnd = zone.endMinutes
            let end = rawEnd <= start ? 24 * 60 : rawEnd
            let visibleStart = max(start, Self.startHour * 60)
            let visibleEnd = min(end, Self.endHour * 60)
            if visibleEnd > visibleStart {
                let height = CGFloat(visibleEnd - visibleStart) / 60 * Self.hourHeight
                let y = yPosition(forMinutes: visibleStart)
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
                .offset(x: labelWidth, y: y)
            }
        }
    }

    @ViewBuilder
    private func hourGrid(labelWidth: CGFloat) -> some View {
        ForEach(Self.startHour...Self.endHour, id: \.self) { hour in
            let y = CGFloat(hour - Self.startHour) * Self.hourHeight
            Text(timeLabel(hour))
                .font(AppFonts.hourLabel)
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: labelWidth - 8, alignment: .trailing)
                .offset(y: y - 7)
            Rectangle()
                .fill(AppColors.textPrimary.opacity(0.08))
                .frame(height: 1)
                .offset(x: labelWidth, y: y)
        }
    }

    private func emptyState(plotWidth: CGFloat) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.run.circle.fill")
                .font(AppFonts.heroSymbol)
                .foregroundStyle(AppColors.accentGreen.opacity(0.8))
            Text(L10n.Schedule.emptyTitle)
                .font(AppFonts.headlineBlack)
            Text(L10n.Schedule.emptySubtitle)
                .font(AppFonts.subheadlineSemibold)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: plotWidth - 20)
        .padding(.vertical, 22)
    }

    private func yPosition(forMinutes minutes: Int) -> CGFloat {
        CGFloat(minutes - Self.startHour * 60) / 60 * Self.hourHeight
    }

    private func timeLabel(_ hour: Int) -> String {
        var components = DateComponents()
        components.hour = hour == 24 ? 0 : hour
        components.minute = 0
        let date = languageManager.calendar.date(from: components) ?? Date()
        return date.formatted(Date.FormatStyle(date: .omitted, time: .shortened, locale: languageManager.locale))
    }
}

private struct TimelineSessionCard: View {
    @Environment(LanguageManager.self) private var languageManager
    let item: TimelineSessionItem
    let onMove: (CGFloat) -> Void
    let onTap: () -> Void
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                Image(systemName: item.isMissed ? "exclamationmark.circle.fill" : "star.fill")
                    .font(AppFonts.caption2IconBlack)
                Text(item.title)
                    .font(AppFonts.subheadlineBlack)
                    .lineLimit(2)
            }
            if item.durationMinutes >= 45 {
                Text(timeText)
                    .font(AppFonts.caption2Bold)
                    .opacity(0.82)
                if item.blocking {
                    Label(L10n.Schedule.yourTime, systemImage: "lock.fill")
                        .font(AppFonts.microHeavy)
                        .opacity(0.75)
                }
            }
        }
        .foregroundStyle(AppColors.onAccent)
        .padding(.horizontal, 11)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(cardColor.gradient, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(AppColors.onAccent.opacity(0.28), lineWidth: 1.5)
        }
        .shadow(color: cardColor.opacity(0.6), radius: isDragging ? 14 : 0, y: isDragging ? 8 : 4)
        .scaleEffect(isDragging ? 1.025 : 1)
        .offset(y: dragOffset)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .gesture(
            DragGesture(minimumDistance: 6)
                .onChanged { value in
                    isDragging = true
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    onMove(value.translation.height)
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.75)) {
                        dragOffset = 0
                        isDragging = false
                    }
                }
        )
        .animation(.spring(response: 0.38, dampingFraction: 0.76), value: isDragging)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(timeText)")
        .accessibilityValue(timeText)
        .accessibilityHint(L10n.Schedule.dragHintAccessibility)
        .accessibilityIdentifier("timeline-task-\(item.title)")
    }

    private var cardColor: Color {
        if item.isMissed { return AppColors.destructive }
        return item.zoneColor
    }

    private var timeText: String {
        let style = Date.FormatStyle(date: .omitted, time: .shortened, locale: languageManager.locale)
        let start = item.start.formatted(style)
        let end = item.end.formatted(style)
        return "\(start)–\(end)"
    }
}

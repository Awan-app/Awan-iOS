import SwiftUI

struct DayTimelineView: View {
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
                        .zIndex(item.isUserFixed ? 3 : 2)
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
        .background(.background, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 16, y: 7)
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
                        .fill(Color(awanHex: zone.colorHex).opacity(0.09))
                    Text(zone.name.uppercased())
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundStyle(Color(awanHex: zone.colorHex).opacity(0.8))
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
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(width: labelWidth - 8, alignment: .trailing)
                .offset(y: y - 7)
            Rectangle()
                .fill(Color.primary.opacity(0.08))
                .frame(height: 1)
                .offset(x: labelWidth, y: y)
        }
    }

    private func emptyState(plotWidth: CGFloat) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.run.circle.fill")
                .font(.system(size: 52, weight: .black))
                .foregroundStyle(Color(awanHex: "#58CC02").opacity(0.8))
            Text("Your day is ready for adventure")
                .font(.system(.headline, design: .rounded, weight: .black))
            Text("Create a quest or try the conflict lab above.")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: plotWidth - 20)
        .padding(.vertical, 22)
    }

    private func yPosition(forMinutes minutes: Int) -> CGFloat {
        CGFloat(minutes - Self.startHour * 60) / 60 * Self.hourHeight
    }

    private func timeLabel(_ hour: Int) -> String {
        if hour == 24 { return "12 AM" }
        if hour == 12 { return "12 PM" }
        return hour < 12 ? "\(hour) AM" : "\(hour - 12) PM"
    }
}

private struct TimelineSessionCard: View {
    let item: TimelineSessionItem
    let onMove: (CGFloat) -> Void
    let onTap: () -> Void
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                Image(systemName: item.isMissed ? "exclamationmark.circle.fill" : "star.fill")
                    .font(.caption2.weight(.black))
                Text(item.title)
                    .font(.system(.subheadline, design: .rounded, weight: .black))
                    .lineLimit(2)
            }
            if item.durationMinutes >= 45 {
                Text(timeText)
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .opacity(0.82)
                if item.isUserFixed {
                    Label("Your time", systemImage: "lock.fill")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .opacity(0.75)
                }
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 11)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(cardColor.gradient, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(.white.opacity(0.28), lineWidth: 1.5)
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
        .accessibilityHint("Drag vertically to change time in fifteen minute steps")
        .accessibilityIdentifier("timeline-task-\(item.title)")
    }

    private var cardColor: Color {
        if item.isMissed { return Color(awanHex: "#FF4B4B") }
        return Color(awanHex: item.zoneColorHex)
    }

    private var timeText: String {
        let start = item.start.formatted(date: .omitted, time: .shortened)
        let end = item.end.formatted(date: .omitted, time: .shortened)
        return "\(start)–\(end)"
    }
}

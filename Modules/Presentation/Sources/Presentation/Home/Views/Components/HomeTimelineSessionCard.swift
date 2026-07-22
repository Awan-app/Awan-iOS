import Common
import Domain
import SwiftUI

struct HomeTimelineSessionCard: View {
    let item: HomeTimelineItem
    let onMove: (CGFloat) -> Void
    let onSetCompletion: (Bool) -> Void
    let onTap: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var completionScale: CGFloat = 1

    var body: some View {
        ZStack(alignment: .topTrailing) {
            cardContent
                .onTapGesture(perform: onTap)

            completionButton
                .padding(.top, 7)
                .padding(.trailing, item.laneCount > 1 ? 7 : 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { cardBackground }
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(cardColor.opacity(0.72), lineWidth: 1.5)
        }
        .shadow(color: cardColor.opacity(0.24), radius: isDragging ? 8 : 2, y: 4)
        .offset(y: dragOffset)
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .accessibilityIdentifier("home-timeline-session-\(item.id.uuidString)")
    }

    private var cardContent: some View {
        HStack(alignment: .top, spacing: item.laneCount > 1 ? 6 : 10) {
            taskDetails
            pointsLabel
            Color.clear
                .frame(width: completionDiameter, height: completionDiameter)
        }
        .padding(.leading, item.laneCount > 1 ? 9 : 14)
        .padding(.trailing, item.laneCount > 1 ? 7 : 10)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .contentShape(Rectangle())
    }

    private var taskDetails: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(item.title)
                    .font(AppFonts.subheadlineBlack)
                    .foregroundStyle(AppColors.brandDarkBlue)
                    .strikethrough(isCompleted, color: AppColors.brandDarkBlue)
                    .lineLimit(2)

                if item.blocking {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(cardColor.opacity(0.85))
                        .accessibilityLabel("Locked session")
                }
            }
            Text(timeText)
                .font(AppFonts.caption2Bold)
                .foregroundStyle(AppColors.brandDarkBlue.opacity(0.82))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var pointsLabel: some View {
        if item.points > 0 {
            Text(item.laneCount == 1 ? "+\(item.points) pts" : "+\(item.points)")
                .font(AppFonts.captionHeavy)
                .foregroundStyle(cardColor)
                .lineLimit(1)
        }
    }

    private var dragHandle: some View {
        VStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 3) {
                    Circle().frame(width: 3.5, height: 3.5)
                    Circle().frame(width: 3.5, height: 3.5)
                }
            }
        }
        .foregroundStyle(cardColor.opacity(0.6))
    }

    private var completionButton: some View {
        Button {
            onSetCompletion(!isCompleted)
        } label: {
            ZStack {
                Circle()
                    .fill(isCompleted ? AppColors.accentGreenDepth : cardColor.opacity(0.28))
                    .offset(y: 3)
                Circle()
                    .fill(isCompleted ? AppColors.accentGreen : AppColors.surface)
                Circle()
                    .stroke(isCompleted ? AppColors.accentGreenDepth : cardColor, lineWidth: 2)
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: item.laneCount > 1 ? 9 : 13, weight: .black))
                        .foregroundStyle(AppColors.onAccent)
                }
            }
            .frame(width: completionDiameter, height: completionDiameter)
            .scaleEffect(completionScale)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isCompleted ? "Mark incomplete" : "Mark complete")
        .onChange(of: isCompleted) { wasCompleted, completed in
            animateCompletion(wasCompleted: wasCompleted, completed: completed)
        }
    }

    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(cardColor)
                .offset(y: 5)
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColors.surface)
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(cardColor.opacity(isCompleted ? 0.12 : 0.06))
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { value in
                isDragging = true
                dragOffset = value.translation.height
            }
            .onEnded { value in
                dragOffset = 0
                isDragging = false
                onMove(value.translation.height)
            }
    }

    private var cardColor: Color {
        item.status == .missed ? AppColors.destructive : item.color
    }

    private var isCompleted: Bool {
        item.status == .completed
    }

    private var completionDiameter: CGFloat {
        item.laneCount > 1 ? 23 : 29
    }

    private var timeText: String {
        "\(item.start.formatted(date: .omitted, time: .shortened))–\(item.end.formatted(date: .omitted, time: .shortened))"
    }

    private func animateCompletion(wasCompleted: Bool, completed: Bool) {
        guard completed, !wasCompleted else { return }
        withAnimation(.easeOut(duration: 0.12)) {
            completionScale = 1.22
        }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(120))
            withAnimation(.spring(response: 0.24, dampingFraction: 0.62)) {
                completionScale = 1
            }
        }
    }
}

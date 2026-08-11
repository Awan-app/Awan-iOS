import Common
import Domain
import SwiftUI
import Foundation

struct DailyWheelDisc: View {
    let segments: [DailyWheelSegment]
    let rotation: Double
    let isSpinning: Bool
    @Environment(\.locale) private var locale

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)

            ZStack(alignment: .top) {
                AppDepthSurface(
                    shape: .circle,
                    surfaceColor: AppColors.wheelRim,
                    borderColor: AppColors.onAccent.opacity(0.72),
                    depthColor: AppColors.wheelRimDepth,
                    borderWidth: 3,
                    depthOffset: 11,
                    contentInsets: EdgeInsets()
                ) {
                    wheelFace(size: size - 24)
                        .padding(12)
                }
                .frame(width: size, height: size)

                WheelPointerShape()
                    .fill(AppColors.onAccent)
                    .overlay {
                        WheelPointerShape()
                            .stroke(AppColors.brandDarkBlue.opacity(0.35), lineWidth: 1.5)
                    }
                    .frame(width: 34, height: 42)
                    .offset(y: -5)
                    .accessibilityHidden(true)
            }
            .frame(width: size, height: size)
        }
    }

    private func wheelFace(size: CGFloat) -> some View {
        ZStack {
            Canvas { context, canvasSize in
                drawSegments(context: &context, size: canvasSize)
                drawTexture(context: &context, size: canvasSize)
            }
            .clipShape(Circle())

            segmentLabels(size: size)

            Circle()
                .stroke(AppColors.onAccent.opacity(0.66), lineWidth: 5)

            studs(size: size)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColors.onAccent,
                            AppColors.infoSurface
                        ],
                        center: .topLeading,
                        startRadius: 2,
                        endRadius: 46
                    )
                )
                .frame(width: size * 0.19, height: size * 0.19)
                .overlay {
                    Circle()
                        .stroke(AppColors.reward.opacity(0.72), lineWidth: 4)
                }
                .overlay {
                    Image(systemName: "sparkles")
                        .font(.system(size: size * 0.075, weight: .black))
                        .foregroundStyle(AppColors.reward)
                        .symbolEffect(.pulse, isActive: isSpinning)
                }
        }
        .rotationEffect(.degrees(rotation))
        .animation(nil, value: isSpinning)
    }

    private func drawSegments(
        context: inout GraphicsContext,
        size: CGSize
    ) {
        guard !segments.isEmpty else { return }
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2
        let angle = 360.0 / Double(segments.count)

        for index in segments.indices {
            let start = Angle.degrees(-90 + Double(index) * angle)
            let end = Angle.degrees(-90 + Double(index + 1) * angle)
            var path = Path()
            path.move(to: center)
            path.addArc(
                center: center,
                radius: radius,
                startAngle: start,
                endAngle: end,
                clockwise: false
            )
            path.closeSubpath()

            let color = AppColors.wheelSegmentPalette[
                index % AppColors.wheelSegmentPalette.count
            ]
            context.fill(path, with: .color(color))
            context.stroke(
                path,
                with: .color(AppColors.onAccent.opacity(0.42)),
                lineWidth: 2
            )
        }
    }

    private func drawTexture(
        context: inout GraphicsContext,
        size: CGSize
    ) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2

        for ring in 1...5 {
            let ringRadius = radius * CGFloat(ring) / 6
            let rect = CGRect(
                x: center.x - ringRadius,
                y: center.y - ringRadius,
                width: ringRadius * 2,
                height: ringRadius * 2
            )
            context.stroke(
                Path(ellipseIn: rect),
                with: .color(AppColors.onAccent.opacity(0.07)),
                lineWidth: 1
            )
        }

        for index in 0..<36 {
            let angle = Double(index) * 10 * .pi / 180
            let dotRadius = radius * (0.42 + CGFloat(index % 4) * 0.12)
            let point = CGPoint(
                x: center.x + CGFloat(Foundation.cos(angle)) * dotRadius,
                y: center.y + CGFloat(Foundation.sin(angle)) * dotRadius
            )
            let rect = CGRect(x: point.x - 1.5, y: point.y - 1.5, width: 3, height: 3)
            context.fill(
                Path(ellipseIn: rect),
                with: .color(AppColors.onAccent.opacity(0.16))
            )
        }
    }

    private func segmentLabels(size: CGFloat) -> some View {
        let angle = 360.0 / Double(max(segments.count, 1))
        let radius = size * 0.32

        return ZStack {
            ForEach(Array(segments.enumerated()), id: \.element.id) { index, segment in
                let degrees = -90 + (Double(index) + 0.5) * angle
                let radians = degrees * .pi / 180

                VStack(spacing: 3) {
                    Image(
                        systemName: segment.payoutType == .item
                            ? "gift.fill"
                            : "star.fill"
                    )
                    .font(.system(size: size * 0.052, weight: .black))

                    Text(
                        segment.payoutType == .item
                            ? L10n.DailyWheel.gift
                            : segment.coins.formatted(.number.locale(locale))
                    )
                    .font(AppFonts.subheadlineBlack)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                }
                .foregroundStyle(AppColors.onAccent)
                .frame(width: size * 0.22)
                .offset(
                    x: cos(radians) * radius,
                    y: sin(radians) * radius
                )
            }
        }
        .frame(width: size, height: size)
    }

    private func studs(size: CGFloat) -> some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(AppColors.onAccent.opacity(index.isMultiple(of: 2) ? 0.95 : 0.68))
                    .frame(width: 7, height: 7)
                    .offset(y: -(size / 2 - 10))
                    .rotationEffect(.degrees(Double(index) * 30))
            }
        }
    }
}

private struct WheelPointerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview("Daily Wheel Light") {
    DailyWheelDisc(
        segments: DailyWheelSegment.previewSegments,
        rotation: 0,
        isSpinning: false
    )
    .frame(width: 360, height: 360)
    .padding()
    .background(AppColors.screenBackground)
}

#Preview("Daily Wheel Dark") {
    DailyWheelDisc(
        segments: DailyWheelSegment.previewSegments,
        rotation: -75,
        isSpinning: false
    )
    .frame(width: 360, height: 360)
    .padding()
    .background(AppColors.screenBackground)
    .preferredColorScheme(.dark)
}

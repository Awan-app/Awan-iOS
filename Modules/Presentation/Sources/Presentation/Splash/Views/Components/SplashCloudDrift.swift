import SwiftUI
import Common

struct SplashCloudDrift: View {
    private static let driftDuration: TimeInterval = 34
    private static let revealStagger: TimeInterval = 0.07
    private static let wrapSpan: CGFloat = 1.34
    private static let wrapOrigin: CGFloat = -0.17

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animationStart = Date.now

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            Canvas { context, size in
                drawSky(in: &context, size: size)

                for (index, cloud) in Cloud.all.enumerated() {
                    draw(
                        cloud,
                        index: index,
                        elapsed: timeline.date.timeIntervalSince(animationStart),
                        in: &context,
                        size: size
                    )
                }
            }
        }
        .frame(height: 180)
        .clipped()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func drawSky(
        in context: inout GraphicsContext,
        size: CGSize
    ) {
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                Gradient(stops: [
                    .init(color: AppColors.splashBackgroundStart, location: 0),
                    .init(color: AppColors.splashSkyMorning, location: 0.62),
                    .init(color: AppColors.splashBackground, location: 1)
                ]),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )
    }

    private func draw(
        _ cloud: Cloud,
        index: Int,
        elapsed: TimeInterval,
        in context: inout GraphicsContext,
        size: CGSize
    ) {
        let reveal = reduceMotion
            ? 1
            : revealProgress(elapsed - Double(index) * Self.revealStagger)
        guard reveal > 0 else { return }

        let drift = reduceMotion
            ? 0
            : CGFloat(elapsed.truncatingRemainder(dividingBy: Self.driftDuration)
                / Self.driftDuration)
        let unwrapped = cloud.baseX + drift * cloud.speed
        let wrapped = positiveRemainder(unwrapped, divisor: Self.wrapSpan)
        let centerX = (Self.wrapOrigin + wrapped) * size.width
        let radius = cloud.radius * size.height * reveal
        let centerY = (
            cloud.y + (1 - reveal) * cloud.radius
        ) * size.height
        let color = AppColors.splashCloudSurface.opacity(
            cloud.alpha * 0.9 * reveal
        )

        for puff in Puff.cluster {
            let puffRadius = radius * puff.scale
            let rect = CGRect(
                x: centerX + puff.dx * radius - puffRadius,
                y: centerY + puff.dy * radius - puffRadius,
                width: puffRadius * 2,
                height: puffRadius * 2
            )
            context.fill(Path(ellipseIn: rect), with: .color(color))
        }
    }

    private func revealProgress(_ elapsed: TimeInterval) -> CGFloat {
        guard elapsed > 0 else { return 0 }

        let time = min(elapsed, 1.2)
        let progress = 1 - exp(-6.2 * time) * cos(9.5 * time)
        return CGFloat(max(0, min(progress, 1.08)))
    }

    private func positiveRemainder(_ value: CGFloat, divisor: CGFloat) -> CGFloat {
        let remainder = value.truncatingRemainder(dividingBy: divisor)
        return remainder >= 0 ? remainder : remainder + divisor
    }
}

private struct Puff {
    let dx: CGFloat
    let dy: CGFloat
    let scale: CGFloat

    static let cluster = [
        Puff(dx: 0, dy: 0, scale: 1),
        Puff(dx: -0.78, dy: 0.2, scale: 0.68),
        Puff(dx: 0.8, dy: 0.24, scale: 0.6),
        Puff(dx: 0.12, dy: -0.44, scale: 0.63),
        Puff(dx: -0.42, dy: -0.2, scale: 0.72)
    ]
}

private struct Cloud {
    let baseX: CGFloat
    let y: CGFloat
    let radius: CGFloat
    let speed: CGFloat
    let alpha: Double

    static let all = [
        Cloud(baseX: 0.08, y: 0.66, radius: 0.30, speed: 1.00, alpha: 1.00),
        Cloud(baseX: 0.44, y: 0.40, radius: 0.22, speed: 0.62, alpha: 0.72),
        Cloud(baseX: 0.72, y: 0.74, radius: 0.35, speed: 1.28, alpha: 0.92),
        Cloud(baseX: 0.94, y: 0.34, radius: 0.18, speed: 0.48, alpha: 0.58),
        Cloud(baseX: 0.26, y: 0.86, radius: 0.26, speed: 1.52, alpha: 0.80)
    ]
}

#Preview("Splash Clouds — Light") {
    SplashCloudDrift()
        .preferredColorScheme(.light)
}

#Preview("Splash Clouds — Dark") {
    SplashCloudDrift()
        .preferredColorScheme(.dark)
}
